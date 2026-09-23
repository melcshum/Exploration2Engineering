# Chapter 3: Model Integration and Context Management

## Scope

This chapter builds directly on the agentic foundations established in Chapter 2. Where Chapter 2 introduced the Plan-and-Execute pattern — with its Planner, Executor, and State Manager — it left one critical resource unexamined: the **context window**. Each step in a Plan-and-Execute agent consumes context. The Planner's LLM call consumes context. The Executor's LLM calls consume context. Step outputs flow into subsequent step inputs, each one filling the context window a little more. Within a few steps, the window fills. Within a few more, the agent breaks.

This chapter addresses that bottleneck systematically. It covers five interconnected topics:

1. **Multi-provider integration** — how to build an abstraction layer that isolates your application from provider-specific API differences, so you can switch models without rewriting the system.
2. **Context window mechanics** — what the context window actually is, how it gets consumed in multi-step agents, and why the fixed-size constraint shapes every architectural decision you make.
3. **Prompt caching and conversation history** — the architectural patterns for managing long interaction histories without losing early context or exceeding token budgets.
4. **Token budgeting as a first-class design discipline** — treating cost and context size as explicit constraints that drive architectural decisions, not as afterthoughts.
5. **Context selection strategies** — the disciplined approach to deciding what enters the context window at each step, what gets excluded, and how exclusion decisions are made systematically.

This chapter does not cover multi-agent orchestration (Chapter 8) or evaluation and guardrails (Chapter 5).

---

## Learning Objectives

By the end of this chapter, students should be able to:

- Design and implement an LLM client abstraction layer that isolates provider-specific API differences behind a common interface.
- Explain what happens to an LLM's context window as a multi-step agent executes, and predict where context exhaustion will occur.
- Compare and evaluate prompt caching, conversation history truncation, and summarization as strategies for managing long interaction contexts.
- Implement token budgeting as an explicit design constraint that governs how context is allocated across agent steps.
- Apply context selection strategies to a given agentic task, deciding systematically what to include and what to exclude from the context window at each step.

---

## Lead-In: When the Plan Runs Out of Room to Think

Chapter 2 ended with the Plan-and-Execute architecture fully operational. We had a Planner that decomposed tasks into steps, an Executor that carried them out, and a State Manager that tracked progress and enabled intelligent replanning. The system could handle a step failing, recover, and continue. It was, by the standards of Chapters 1 and 2, a robust design.

And yet there was an unexamined assumption running through every line of that code: **the context window was always big enough for whatever we wanted to put into it**. We passed the entire file contents to the refactoring step without asking whether it would fit. We passed the refactored output to the test-writing step without checking whether the combined prompt exceeded the model's maximum. We assumed that the LLM's context window was a generous, effectively unlimited resource.

It is not.

The context window is a **fixed-size buffer**. Every token that enters the context window — the system prompt, the task description, the conversation history, the retrieved documents, the step outputs from prior steps — occupies part of that buffer. When the buffer fills, the model cannot accept more input. In some API implementations, new input simply overwrites old input at the beginning of the window. In others, the API call returns an error. Either way, **information that was in the context gets lost**.

In a Plan-and-Execute agent with four or five steps, each producing non-trivial output, context exhaustion is not a theoretical concern. It is a near-term certainty. The refactored Python file (200 tokens) plus the test file (150 tokens) plus the Planner's output (80 tokens) plus the conversation history (300 tokens) already consumes a meaningful fraction of a 128,000-token window — before we account for the system prompt, the task instructions, and the provider's own framing.

This is the bottleneck Chapter 3 addresses. It is not a performance optimization or a cost-cutting exercise. **Context management is an architectural discipline** — as fundamental to agentic system design as state management was in Chapter 2. Ignoring it produces systems that appear to work in testing and fail in production, not because of a logic error, but because the context window ran out of space.

---

## Multi-Provider Integration

### The Provider Abstraction Problem

Every LLM provider — OpenAI, Anthropic, Google, local Ollama — exposes a different API. Request formats differ. Response structures differ. Authentication mechanisms differ. The model names differ. If your application code is written directly against the OpenAI API, switching to Anthropic requires rewriting every LLM call throughout the system. In a Plan-and-Execute agent where the Planner and Executor both call the LLM, that means rewriting at least two components.

This is not an academic concern. Provider mix matters in production. OpenAI's models are capable but expensive and subject to rate limits. Anthropic's Claude models offer strong reasoning at different price points. Local Ollama deployments eliminate API costs entirely but introduce latency and hardware constraints. A production agentic system should be able to route different task types to different providers based on cost, capability, and availability requirements — without rewriting the application layer.

The solution is an **LLM client abstraction layer**: a typed interface that your application code calls, with concrete provider implementations behind that interface. This is a specific application of the Adapter pattern from object-oriented design. The application layer depends on the abstract interface, not the concrete implementation. Swapping providers becomes a configuration change, not a code change.

### Designing the LLM Client Interface

The interface should expose the minimal set of operations that your application actually needs. At minimum, that means a single method: `generate(prompt: str, options: GenerationOptions) -> GenerationResult`. Everything else in the interface — model selection, temperature, max tokens, streaming — belongs in the `GenerationOptions` parameter, not as separate methods that would fragment the interface across providers.

```python
from dataclasses import dataclass
from typing import Protocol, Literal
from abc import ABC, abstractmethod

@dataclass
class GenerationOptions:
    model: str | None = None          # provider-specific model identifier
    temperature: float = 0.0          # 0 = deterministic, 1 = creative
    max_tokens: int | None = None    # override provider default
    stop_sequences: list[str] | None = None

@dataclass
class GenerationResult:
    content: str                      # the generated text
    model: str                        # model that produced the response
    tokens_used: int                  # total tokens consumed
    finish_reason: Literal["stop", "length", "error"]

class LLMClient(Protocol):
    """Abstract interface for LLM provider access."""

    def generate(
        self,
        prompt: str,
        options: GenerationOptions | None = None
    ) -> GenerationResult:
        """Generate a response from the given prompt."""
        ...
```

The `Protocol` class from Python's `typing` module makes this a structural subtype — any class that implements `generate` with the correct signature satisfies the interface, without requiring explicit inheritance. This makes testing straightforward: you can provide a mock implementation that returns hardcoded responses without calling any real API.

### Provider Implementations

Each concrete provider implementation wraps that provider's SDK and maps its specific request/response format to the abstract interface. The OpenAI implementation looks like this:

```python
from openai import OpenAI

class OpenAIClient:
    def __init__(self, api_key: str):
        self._client = OpenAI(api_key=api_key)

    def generate(
        self,
        prompt: str,
        options: GenerationOptions | None = None
    ) -> GenerationResult:
        options = options or GenerationOptions()
        kwargs: dict = {
            "model": options.model or "gpt-4o",
            "messages": [{"role": "user", "content": prompt}],
        }
        if options.temperature is not None:
            kwargs["temperature"] = options.temperature
        if options.max_tokens is not None:
            kwargs["max_tokens"] = options.max_tokens

        response = self._client.chat.completions.create(**kwargs)
        choice = response.choices[0]

        return GenerationResult(
            content=choice.message.content or "",
            model=response.model,
            tokens_used=response.usage.total_tokens,
            finish_reason=choice.finish_reason or "stop",
        )
```

An `AnthropicClient` follows the same interface contract but calls the Claude API with its own request format. The two implementations are **interchangeable at the call site** — the application code calls `client.generate(prompt, options)` without knowing which provider is configured. This is the abstraction layer's primary value.

### Provider Selection as a Policy Decision

Having an abstraction layer makes provider selection a **policy decision** — runtime configuration — rather than a code decision. Your agent can route different task types to different providers based on cost, capability, or availability requirements.

A simple routing policy might look like this:

```python
def create_router() -> LLMClient:
    """Create a routing LLM client based on environment configuration."""
    provider = os.environ.get("LLM_PROVIDER", "openai")

    match provider:
        case "anthropic":
            return AnthropicClient(api_key=os.environ["ANTHROPIC_API_KEY"])
        case "ollama":
            return OllamaClient(base_url=os.environ["OLLAMA_BASE_URL"])
        case _:
            return OpenAIClient(api_key=os.environ["OPENAI_API_KEY"])
```

More sophisticated routing can dispatch different models for different step types in a Plan-and-Execute agent. The Planner might use a powerful, expensive model (for better plan quality) while the Executor uses a smaller, cheaper model (for routine step execution). This is a **cost optimization** that the abstraction layer makes straightforward to implement.

---

## Context Window Mechanics

### What the Context Window Actually Is

The context window is not a soft, flexible container that expands as needed. It is a **fixed-size hardware buffer** inside the transformer's attention mechanism — or, in the case of API-accessible models, a fixed-size logical limit enforced by the provider's inference infrastructure. Every token you send to the model occupies one slot in that buffer. When the buffer is full, there is no more space.

This has a direct consequence that is easy to overlook: **every token you send to the model has an opportunity cost**. The system prompt consumes tokens. The conversation history consumes tokens. The task description consumes tokens. The context you retrieved from the vector database consumes tokens. And every step output in a Plan-and-Execute agent consumes tokens. These are not free resources. They are a fixed budget, and you are spending them every time you make an API call.

Understanding this concretely changes how you design prompts. A system prompt of 1,500 tokens is not just verbose — it permanently reduces the space available for the actual task. A conversation history of 50 messages at 200 tokens each consumes 10,000 tokens on every API call, whether those messages are relevant to the current query or not. A RAG retrieval that returns 20 chunks at 300 tokens each consumes 6,000 tokens before the model has generated a single output token.

The discipline this requires is **context accounting**: treating every token as a spent resource whose value must be justified by its contribution to the quality of the generated response.

### How Context Gets Consumed in Multi-Step Agents

In a Plan-and-Execute agent, the context window is not consumed once — it is consumed repeatedly, at every step, and the consumption accumulates.

Consider the refactor-and-test task from Chapter 2. At step one, the Executor reads a 300-token source file. At step two, it calls the LLM to refactor that file, passing the file contents plus a 200-token instruction. The Planner's LLM call at step three consumes another 500 tokens. The Executor's call at step three consumes the 200-token refactored output plus the original file plus the instruction again. By step five, the cumulative context consumption has grown substantially — and this is a short task with small files.

In a production agent handling real codebases, the step outputs are much larger. A step that retrieves relevant documentation might return 5,000 tokens of context. A step that reads a source file might return 3,000 tokens. A step that writes a refactored file might produce 4,000 tokens of output. Each of these accumulates in the context window across steps, and each subsequent step's LLM call must include the accumulated history to maintain coherence.

The failure mode is predictable: **context window exhaustion at step N**, where step N is the first step whose total context size (system prompt + conversation history + task description + step outputs + new input) exceeds the model's maximum. When this happens, the model either silently drops early context (in models with rolling context windows) or returns an error (in models with hard limits). Either way, the agent loses access to information it needed.

### The Fixed Budget Problem

The fixed-size context window creates a **budget allocation problem**: given a fixed token budget, how do you allocate tokens across the components of a multi-step agent to maximize overall task success?

The naive answer — "include everything" — is not available. You cannot include all conversation history, all step outputs, all retrieved context, and all instructions simultaneously. At some point, the budget is exhausted. The real architectural question is: **given a specific task and a specific context window size, what do you include, what do you exclude, and on what basis do you make those decisions?**

This is the question that the rest of this chapter answers. The answer is not "include the most recent tokens" (which ignores that early context may be essential). It is not "include everything relevant to the current step" (which ignores that relevance is hard to determine without the full context). The answer is a **systematic decision framework** — context selection strategies — that makes the exclusion decisions explicit, auditable, and testable.

---

## Excalidraw Visual Specification: Context Window Consumption Across Steps

Create an Excalidraw diagram with the following structure:

**Canvas size:** 1100 × 650 px

**Title:** "Context Window Consumption Across Steps" — centered at top, font size 18, bold.

**Main area: two-column layout**

**Left column (400 px wide) — "Step Execution Flow":**

- Draw 5 stacked rounded rectangles (one per step), each 360 × 52 px, stacked vertically with 8px gaps:
  - Step 1: "Read Source" — fill: `#e3f2fd`, stroke: `#1565c0`
  - Step 2: "Refactor to Generator" — fill: `#e8f5e9`, stroke: `#2e7d32`
  - Step 3: "Validate Code" — fill: `#fff3e0`, stroke: `#e65100`
  - Step 4: "Write Refactored File" — fill: `#fce4ec`, stroke: `#c2185b`
  - Step 5: "Write Tests" — fill: `#f1f8e9`, stroke: `#558b2f`

- Below the stacked boxes, add a downward-pointing arrow (solid, `#9e9e9e`) labeled "Execution order"

**Right column (620 px wide) — "Context Window State at Each Step":**

- Draw 5 horizontal bar chart rows (one per step), each row: a label on the left (step name, 120 px wide) + a horizontal bar filling rightward:

  - Row 1 (Step 1 — Read Source): Three segments in the bar:
    - System prompt + task: 800 tokens — fill: `#90a4ae`, width: 80 px (proportional)
    - Source file content: 300 tokens — fill: `#1565c0`, width: 30 px
    - Remaining capacity: ~127,000 tokens — fill: `#eceff1`, width: ~400 px
    Total label on right: "8,300 / 128,000 tokens"

  - Row 2 (Step 2 — Refactor): Same segments but add a new segment:
    - Prior context (Step 1 output): 200 tokens — fill: `#42a5f5`, width: 20 px
    - New segment appears at right end: "Refactor instruction: 200 tokens" — fill: `#2e7d32`, width: 20 px
    Total label: "8,500 / 128,000 tokens"

  - Row 3 (Step 3 — Validate): Bar fills further:
    - Segments: System+task (800), Source (300), Refactored output (2000), Instruction (200) = ~3,300 tokens — total bar now ~120 px wide
    - New segment: Validation code (50 tokens) — fill: `#e65100`, width: 5 px
    Total label: "3,350 / 128,000 tokens"

  - Row 4 (Step 4 — Write Refactored File): Bar continues:
    - Segments cumulative: ~5,350 tokens — total bar ~145 px wide
    - New segment: Write instruction (150 tokens) — fill: `#c2185b`, width: 15 px
    Total label: "5,500 / 128,000 tokens"

  - Row 5 (Step 5 — Write Tests): Bar near same width (no new large inputs):
    - Total: ~5,700 tokens — bar ~150 px wide
    - Total label: "5,700 / 128,000 tokens"

- Below the bar chart, add a **red dashed vertical line** at ~75% of the bar chart width, labeled "Context exhaustion threshold (hypothetical)" in small italic text.

**Key annotations (add callout text boxes):**

- Near Row 1 bar: "Token budget is fixed — every token spent here reduces capacity for later steps"
- Near Row 5 bar: "Cumulative step outputs accumulate across the agent's lifetime — they do not reset between steps"
- At the bottom: "Note: This is a simplified model. Real context consumption depends on provider-specific token counting, system prompt length, and whether prior turns are re-sent in full."

**Color legend (bottom-left corner):**
- Small square + label pairs:
  - `#90a4ae` → System prompt + task
  - `#1565c0` → Source/input content
  - `#42a5f5` → Prior step outputs (accumulating)
  - `#2e7d32` → Instruction/prompt tokens
  - `#eceff1` → Unused context capacity

---

## Prompt Caching and Conversation History

### Why Conversation History Becomes a Problem

In a single-question RAG system, conversation history is usually not an issue — the user asks one question, the system retrieves context, the model generates a response, and the interaction ends. There is no history to manage.

In an agentic system, the interaction is multi-step. The user asks a question, the agent plans, the agent executes steps, the user asks a follow-up, the agent continues. This generates a **conversation history** that grows with every exchange. If that history is sent in full to every subsequent LLM call, the context window fills with old exchanges that may no longer be relevant to the current task.

Consider a debugging session: the user describes a bug, the agent reads a file, the agent proposes a fix, the user confirms, the agent implements the fix, the user asks about a side effect, the agent reviews the change. That is six exchanges before the session is over. If each exchange averages 400 tokens, the conversation history alone consumes 2,400 tokens per LLM call — before any actual task content is included.

The challenge is that **not all history is equally dispensable**. Some exchanges establish constraints that remain in force for the entire session ("we are using Python 3.12 specifically"). Some exchanges are dead ends — wrong hypotheses that were tried and abandoned. Some exchanges contain critical intermediate decisions that the agent must remember to maintain coherence. The discipline of conversation history management is the discipline of distinguishing between these cases.

### Caching Architectures

**Prompt caching** is a provider-side optimization in which the provider stores a hashed representation of recent prompt context and reuses it across API calls without retransmitting the full tokens. OpenAI's cached completions API and Anthropic's prompt caching feature work on this principle: if your system prompt or conversation history has not changed since the last call, the provider can reuse the cached computation without charging you for those tokens again.

Caching is not free, however. Cached tokens have a **time-to-live** — typically 5 to 10 minutes. After that window expires, the cache is invalidated and the tokens must be retransmitted at full cost. For short-running agentic tasks (a RefactorAgent that completes in 30 seconds), this is fine. For long-running sessions (a debugging session that spans an hour), the cache invalidation becomes a real cost.

More importantly, caching does not solve the **context window exhaustion problem** — it only reduces the cost of repeated identical context. The context window itself still has a fixed size. If your conversation history plus step outputs plus retrieved context exceeds the window limit, caching the history does not help. You still need to manage what goes into the window in the first place.

### Truncation and Summarization as Competing Strategies

When the conversation history grows too large to include in full, two strategies are available:

**Truncation** removes the oldest exchanges, keeping only the most recent N tokens of history. This is simple to implement but risks losing critical context from early in the session. If the session started with a constraint established in the first exchange ("use a specific API version", "the codebase uses Python 3.11"), and that exchange is truncated, the agent loses awareness of the constraint.

**Summarization** condenses the conversation history into a shorter representation — a summary that captures the key facts, decisions, and constraints without the full back-and-forth. This preserves more information per token but requires an additional LLM call (to generate the summary) and introduces summarization latency and cost. It also risks losing nuance: a summary of "the user confirmed the fix was correct" is not the same as the original exchange in which the user said "yes, but check the edge case where the list is empty."

The choice between truncation and summarization depends on the session length, the stakes of losing early context, and the cost budget available for summary generation. A practical hybrid approach: **truncate conservatively** (keep more history than you think you need) and use summarization selectively when the truncated portion contains decisions that affect later steps.

---

## Token Budgeting as a First-Class Design Discipline

### From Afterthought to Constraint

Most AI-supported systems treat token usage as an **output metric** — something to be measured after the fact, perhaps displayed in a UI, but not something that shapes the architecture. Token counts appear in API response metadata. Usage dashboards show costs. But the system design itself proceeds as if tokens are infinite.

This is the wrong orientation. In a production system, token budget is a **first-class constraint** — as real as response latency or error rate. An agent that runs 10,000 tokens per task at $0.01 per 1,000 tokens costs $0.10 per task. At 1,000 tasks per day, that is $100 per day. At 100,000 tasks per day, that is $10,000 per day. The difference between a well-budgeted agent (using smaller models for routine steps, including only relevant context) and a careless one (sending full conversation history, large system prompts, and unnecessary retrieved context at every step) can easily be a factor of 5× to 10× in cost.

**Token budgeting as a design discipline** means making cost and context size explicit constraints *before* writing the architecture, not after. It means asking, at each step: what is the maximum tokens I can afford to spend on this step? What context do I actually need to include to get a good result? What can I exclude without meaningfully degrading output quality?

### A Cost Model for Plan-and-Execute Agents

A simple cost model for a Plan-and-Execute agent estimates cost per step as:

```
cost_per_step = (input_tokens × input_cost_per_1k)
              + (output_tokens × output_cost_per_1k)
              + (fixed_per_call_overhead)
```

The `input_cost_per_1k` and `output_cost_per_1k` are provider-specific rates (e.g., OpenAI gpt-4o: ~$0.005 input / $0.015 output per 1,000 tokens; Anthropic Claude 3.5 Sonnet: ~$0.003 input / $0.015 output per 1,000 tokens). The `fixed_per_call_overhead` accounts for API call overhead — typically negligible but worth tracking for high-frequency calls.

For a 5-step agent with an average of 2,000 input tokens and 500 output tokens per step, using gpt-4o:
- Input cost: 5 steps × 2,000 tokens × $0.005/1k = $0.05
- Output cost: 5 steps × 500 tokens × $0.015/1k = $0.0375
- **Total per task: ~$0.0875**

If the Planner uses a more powerful model (gpt-4o with a larger context) at 5,000 input tokens per call, and the Executor uses a smaller, cheaper model (gpt-4o-mini at 1,000 input tokens per step):
- Planner: 5,000 × $0.005 = $0.025
- Executor: 4 steps × 1,000 × $0.0015 = $0.006
- **Total per task: ~$0.031** — a 3× cost reduction

This is the kind of analysis that token budgeting enables. By selecting models based on the actual requirements of each step — not using the most powerful model everywhere — you can dramatically reduce cost without degrading output quality.

### Budget Allocation Across Agent Steps

A token budget can be allocated **per-step** or **across the entire task**. Per-step budgeting sets a maximum tokens for each individual step's input. Across-task budgeting sets a total token budget for the entire task and distributes it across steps.

The across-task approach is more powerful for multi-step agents because it creates a **global optimization constraint**: if step 2 consumes more tokens than budgeted, that consumption must be recovered from steps 3, 4, or 5. This prevents any single step from carelessly consuming tokens that other steps will need.

A simple across-task budget allocator:

```python
@dataclass
class TokenBudget:
    total_limit: int                         # max tokens for the entire task
    step_limits: dict[str, int]              # per-step overrides

    def allocate(self, plan: list[str]) -> dict[str, int]:
        """Distribute the total budget across steps in the plan."""
        base_allocation = self.total_limit // len(plan)
        allocations = {}
        remaining = self.total_limit

        for i, step in enumerate(plan):
            limit = self.step_limits.get(step, base_allocation)
            # Last step gets any leftover budget
            if i == len(plan) - 1:
                limit = remaining
            allocations[step] = limit
            remaining -= limit

        return allocations
```

At each step, the Executor checks its allocation before building the prompt. If the prompt exceeds the allocation, context selection strategies (the next section) are invoked to reduce the context to fit within the budget. This is **budget-driven context selection**: not "include everything relevant" but "include the most important content up to the budget limit."

---

## Context Selection Strategies

### The Fundamental Selection Problem

Context selection is the problem of deciding, given a set of candidate context items (retrieved documents, conversation history, step outputs, system instructions) and a fixed token budget, which items to include and which to exclude. This is not the same as retrieval ranking. A RAG retriever ranks documents by relevance to the query. A context selector must rank by **importance to the specific step's task**, which is often different from relevance to the query.

Consider a context item: the user's first message, two hours ago, establishing a key constraint ("we are targeting Python 3.11 specifically due to a library dependency"). This message may be entirely irrelevant to the current query — which is about a specific function — but it is critically important to the task because it constrains what code the agent can produce. A pure relevance-based selector would exclude it. A context selector that understands **semantic dependencies across the session** must retain it.

### Layered Context Architecture

A robust context selection approach uses **layered context architecture**: the context window is organized into layers, each with a different retention priority, and items are included or excluded based on which layer they occupy.

**Layer 1 — Immutable constraints** (highest retention priority): API version constraints, language constraints, business rules that were established early in the session. These are retained indefinitely — they never get truncated or summarized. If the context window fills completely, these are the last items to be removed.

**Layer 2 — Session state** (medium-high retention): Current plan, completed steps, current step, intermediate outputs that feed into subsequent steps. These are retained for the duration of the task but may be summarized or compacted once they exceed their budget.

**Layer 3 — Recent context** (medium retention): The most recent N turns of conversation, recent retrieved documents relevant to the current task. These are retained with a sliding window — oldest turns are truncated as new ones are added.

**Layer 4 — Background context** (low retention): Broad retrieved context, general documentation, anything not directly relevant to the immediate step. These are the first items excluded when the context window approaches its limit.

This layered architecture makes the exclusion decision **explicit and auditable**. When the system excludes a context item, it can log which layer the item occupied and why it was excluded. When a step fails because critical context was missing, the audit log reveals whether the context was in Layer 4 (correctly excluded) or Layer 1 (incorrectly excluded).

### Relevance Scoring for Context Items

Within each layer, context items can be ranked by **relevance scoring** — a numeric score that reflects the item's estimated importance to the current step's task. The scoring function is application-specific, but a general approach:

```python
from dataclasses import dataclass

@dataclass
class ScoredContextItem:
    item_id: str
    content: str
    layer: int                       # 1 = highest priority
    relevance_score: float           # higher = more important
    token_count: int

def select_context(
    candidates: list[ScoredContextItem],
    budget: int
) -> list[ScoredContextItem]:
    """
    Select context items within the token budget,
    prioritizing by layer then by relevance score.
    """
    # Sort by layer (ascending = higher priority first),
    # then by relevance score (descending = more important first)
    sorted_items = sorted(
        candidates,
        key=lambda x: (x.layer, -x.relevance_score)
    )

    selected = []
    used_tokens = 0

    for item in sorted_items:
        if used_tokens + item.token_count <= budget:
            selected.append(item)
            used_tokens += item.token_count

    return selected
```

This function preserves items from lower-numbered layers first (Layer 1 before Layer 2), and within the same layer, includes the most relevant items first. It stops when the budget is exhausted. The result is a deterministic, auditable selection that always respects the token budget.

### What Gets Excluded and Why

The hardest context selection decisions involve items that are **ambiguously relevant**: they might be important, but they might not be. A retrieved document about Python's garbage collection might be relevant if the agent is debugging a memory leak, but irrelevant if it is refactoring a function that has nothing to do with memory management.

The conservative approach — include everything that might be relevant — produces a context that is too large. The aggressive approach — include only what is certainly relevant — risks missing critical context. The practical solution is to use a **confidence threshold**: include context items whose relevance score exceeds a tunable threshold, and log excluded items so that exclusions can be reviewed if a step fails.

This is analogous to a **retrieval threshold in a RAG system** (Chapter 1): you do not return every retrieved chunk, only those above a relevance threshold. The difference is that context selection applies the threshold across all layers — retrieved documents, conversation history, step outputs — not just retrieved chunks. The architecture is the same; the scope is broader.

---

## Excalidraw Visual Specification: Layered Context Architecture

Create an Excalidraw diagram with the following structure:

**Canvas size:** 1000 × 650 px

**Title:** "Layered Context Architecture for Multi-Step Agents" — centered at top, font size 18, bold.

**Main structure: vertical stack, top to bottom**

**Context Window Box (center of canvas):**

- Large rounded rectangle, fill: `#f5f5f5`, stroke: `#455a64`, stroke width: 3, size: 700 × 420 px, centered horizontally.

- Inside the box, draw 4 horizontal bands (separated by dashed lines):

  - **Band 1 (top, 80 px tall):** Label "Layer 1 — Immutable Constraints" — fill: `#e8f5e9`, stroke: `#2e7d32`, stroke width: 2. Label inside: "API versions, language constraints, business rules". Below label: two small rounded rectangles representing context items:
    - Left item: "Python 3.11 target" — fill: `#c8e6c9`, stroke: `#2e7d32`, size: 140 × 30
    - Right item: "Use Anthropic for planning" — fill: `#c8e6c9`, stroke: `#2e7d32`, size: 180 × 30

  - **Band 2 (80 px tall):** Label "Layer 2 — Session State" — fill: `#e3f2fd`, stroke: `#1565c0`, stroke width: 2. Label inside: "Current plan, completed steps, step outputs". Three small items:
    - "Plan: [step1, step2, step3]" — fill: `#bbdefb`, stroke: `#1565c0`, size: 160 × 30
    - "Step 1 output: refactored" — fill: `#bbdefb`, stroke: `#1565c0`, size: 170 × 30
    - "Step 2 output: validated" — fill: `#bbdefb`, stroke: `#1565c0`, size: 160 × 30

  - **Band 3 (80 px tall):** Label "Layer 3 — Recent Context" — fill: `#fff3e0`, stroke: `#e65100`, stroke width: 2. Label inside: "Recent turns, relevant retrieved docs". Three small items:
    - "User: fix the bug in calculate_total" — fill: `#ffe0b2`, stroke: `#e65100`, size: 200 × 30
    - "Agent: I found it in line 42" — fill: `#ffe0b2`, stroke: `#e65100`, size: 170 × 30
    - "Doc: calculate_total() ref" — fill: `#ffe0b2`, stroke: `#e65100`, size: 160 × 30

  - **Band 4 (80 px tall):** Label "Layer 4 — Background Context" — fill: `#fce4ec`, stroke: `#c2185b`, stroke width: 2. Label inside: "General docs, broad retrieval (excluded first)". One item (grayed out slightly):
    - "Doc: Python garbage collection" — fill: `#f8bbd9`, stroke: `#c2185b`, stroke width: 1, opacity: 0.5, size: 180 × 30

**Token budget indicator (right side of Context Window Box):**

- Vertical bar to the right of the bands, 60 px wide, full height of the window box.
- Fill from bottom upward with a gradient: bottom = `#eceff1` (unused capacity), top = `#78909c` (used capacity).
- At the top of the used portion, add a small label: "Token budget: 8,500 / 128,000"

**Selection Flow (left side of canvas, 200 px left of window box):**

- Draw a vertical arrow pointing right into the Context Window Box, labeled "Context candidates"
- Above the arrow, add three small candidate boxes stacked vertically:
  - "Doc: RFC 7231 cache" — fill: `#fce4ec`, stroke: `#c2185b`, size: 130 × 28
  - "Turn: user asks about bug" — fill: `#fff3e0`, stroke: `#e65100`, size: 130 × 28
  - "Constraint: Python 3.11" — fill: `#e8f5e9`, stroke: `#2e7d32`, size: 130 × 28

**Output (right side of window box):**

- Arrow pointing right out of the Context Window Box, labeled "Selected context → LLM"

**Legend (bottom-left):**

- Small rounded rectangle, fill: `#fafafa`, stroke: `#bdbdbd`, size: 300 × 120.
- Text inside:
  - "Layer priority: 1 > 2 > 3 > 4"
  - "Within same layer: sort by relevance score"
  - "Excluded items logged for audit"

---

## Lead-Out: The Provider Diversity Bottleneck and the Multi-Agent Horizon

The context management discipline established in this chapter addresses one of the bottlenecks that Chapter 2's Plan-and-Execute architecture created. But it creates a new one: **single-provider constraint**.

Every component we built this chapter — the LLM client abstraction, the token budget allocator, the layered context selector — assumed a single LLM provider configured at startup. In production, this is a fragility. If the Anthropic API is unavailable for 30 minutes, a single-provider agent cannot complete tasks that could have been handled by OpenAI. If a new model is released that is dramatically better for planning tasks, a single-provider agent cannot take advantage of it without a code deployment.

Chapter 8 addresses this directly through **multi-agent orchestration**: how to coordinate multiple agents, each potentially using a different provider, working simultaneously on different aspects of a complex task. The context selection strategies from this chapter will feed directly into that architecture: when multiple agents share a pool of context, the question of which agent gets access to which context items — and under what budget constraints — becomes a multi-agent resource allocation problem.

The architecture continues to advance. Each chapter adds capabilities while exposing new constraints. This is the nature of engineering.

---

## Review & Discussion

1. **Explain the difference between context management and context selection.** Context management is the broader discipline; context selection is one specific decision within it. In a Plan-and-Execute agent with five steps, which specific decisions at each step constitute context management, and which constitute context selection? Be precise about the scope of each term.

2. **The token budget was introduced as a first-class design constraint rather than an output metric.** What are the architectural consequences of treating token budget as an output metric (something measured after the fact) versus as an input constraint (something that shapes the design)? Choose a specific architectural decision — such as how many context items to retrieve per step, or how long the system prompt should be — and walk through the decision differently under each orientation.

3. **Describe the tradeoffs between truncation and summarization for managing conversation history.** In your analysis, consider: the types of context that are safely truncatable, the types of context that are not, the computational cost of summarization, and the risk of losing nuance in the summary. Under what conditions would you choose truncation over summarization, and under what conditions would you choose the reverse?

4. **The layered context architecture assigns retention priority to context items.** What are the failure modes of this approach? Specifically: what happens when a context item is assigned to the wrong layer (e.g., an immutable constraint placed in Layer 3)? What happens when the layer boundaries themselves are set incorrectly (e.g., Layer 4 is made too large, consuming budget needed for Layer 2)? How would you detect and correct these misplacements?

5. **Consider a cost optimization in which the Planner uses an expensive powerful model and the Executor uses a cheaper smaller model.** What are the limits of this optimization? Under what conditions does the cost saving from using a cheaper Executor model get offset by quality degradation — where the cheaper model produces outputs that require additional steps, retry loops, or human intervention? How would you detect this condition in production?

---

## Conceptual Lab: Build a Token-Aware Plan-and-Execute Agent

In this lab, you will extend the Plan-and-Execute agent from Chapter 2 to include token budgeting, context selection, and a multi-provider abstraction layer. The lab is divided into four parts.

### Lab Setup

```bash
mkdir ~/context-aware-agent && cd ~/context-aware-agent
pip install openai python-dotenv dataclasses
```

Create `.env`:

```
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
```

### Part 1 — LLM Client Abstraction Layer

Create `llm_client.py`. Define the abstract interface and two concrete implementations:

- `LLMClient` (Protocol): `generate(prompt, options) -> GenerationResult`
- `OpenAIClient`: wraps the OpenAI SDK
- `AnthropicClient`: wraps the Anthropic SDK (use the `anthropic` Python package)

Test by instantiating each client and calling `generate("Say hello in one word.", options)` on both. Verify both return a `GenerationResult` with the correct fields.

### Part 2 — Token Budget Allocator

Create `token_budget.py`. Implement:

- `TokenBudget` dataclass with `total_limit: int` and `step_limits: dict[str, int]`
- `TokenBudgetAllocator.allocate(plan: list[str], budget: TokenBudget) -> dict[str, int]` — distributes budget across steps, giving the last step any remainder

Then create a `ContextSelector` that uses a budget allocation to select context items:

```python
def select_context(
    candidates: list[ScoredContextItem],
    budget: int
) -> list[ScoredContextItem]:
    # Sort by layer (ascending = higher priority first),
    # then by relevance score (descending)
    # Include items until budget is exhausted
    pass
```

### Part 3 — Instrument the Executor with Budget Tracking

Modify the `PlanAndExecuteAgent` from Chapter 2 to:

- Accept a `TokenBudget` in its constructor
- Accept an `LLMClient` (Protocol type) so it can work with any provider
- Track `tokens_used` across all steps
- Before each step's prompt is built, call `select_context` to fit within the step's token allocation
- Log each step's token usage to the state

Run the agent with a budget of 8,000 tokens total. Observe:
- Which steps consume the most tokens?
- At which step does the context selection start excluding items?
- Is the final output quality affected by the budget constraint?

### Part 4 — Provider Routing

Add a `RouterClient` that routes calls to different providers based on step type:

```python
class RouterClient:
    def __init__(
        self,
        planner_client: LLMClient,
        executor_client: LLMClient,
    ):
        self._planner_client = planner_client
        self._executor_client = executor_client

    def generate(self, prompt: str, options: GenerationOptions | None = None) -> GenerationResult:
        step_type = getattr(options, 'step_type', 'executor')
        client = (self._planner_client if step_type == 'planner'
                  else self._executor_client)
        return client.generate(prompt, options)
```

Configure the agent to use OpenAI for the Planner and a cheaper model for the Executor. Compare cost and quality against single-provider runs.

### Extension (if time allows)

Add a `BudgetExceeded` exception that fires when a step's prompt would exceed its allocation. Implement **context compression**: when the exception fires, the system summarizes the current step output (using an additional LLM call) to reduce its token footprint, then retries the step. Measure how many additional LLM calls compression requires and whether the compressed context still produces acceptable outputs.

---

## Diagramming Exercise

Using **Mermaid**, produce a system diagram for the token-aware Plan-and-Execute agent described in this chapter. Your diagram should include:

1. The three main components: Planner, Executor, State Manager (from Chapter 2).
2. The two new components introduced in this chapter: `LLMClient` abstraction (with OpenAI and Anthropic concrete implementations), `TokenBudgetAllocator`.
3. The `ContextSelector` as a component that sits between the Executor and the LLM client, filtering context before it reaches the LLM.
4. The `TokenBudget` as a configuration object passed into the system at startup.
5. The data flow: `TokenBudget` → `TokenBudgetAllocator` → per-step budget → `ContextSelector` → filtered context → `LLMClient` → `GenerationResult` → `StateManager`.

Use Mermaid `flowchart` syntax with subgraphs to group related components. Include a legend explaining the color coding. Then, in 2–3 paragraphs, write an architectural review: What does this diagram reveal about the relationship between token budgeting and error handling? What does the code make obvious that the diagram does not?

---

## Summary

This chapter addressed the context window bottleneck that Chapter 2's Plan-and-Execute architecture created. We examined context management as a first-class architectural discipline — not an afterthought measured after the fact, but a constraint that shapes every design decision.

We built a multi-provider abstraction layer that isolates the application from provider-specific API differences, enabling provider switching as a configuration decision rather than a code change. We examined context window mechanics to understand why a fixed-size buffer creates a budget allocation problem that pervades every level of agentic system design. We evaluated prompt caching, conversation history truncation, and summarization as strategies for managing growing context — concluding that each has a role and that the choice depends on session length, context type, and cost constraints.

Token budgeting as a first-class design discipline transforms cost and context size from output metrics into input constraints. By allocating a total token budget across a plan's steps and enforcing it at each step, the system prevents the silent context exhaustion that otherwise causes late-step failures in multi-step agents.

Context selection strategies complete the picture: layered context architecture assigns retention priority to context items, ensuring that the most critical constraints and state are retained even when budget is exhausted. A relevance scoring function within each layer ensures that, within a budget, the most important items are included first. The result is a deterministic, auditable selection process that always fits within the token budget.

The architecture advances. Each chapter adds capabilities while exposing new constraints. The next chapter addresses the provider diversity bottleneck through multi-agent orchestration — and the context selection discipline from this chapter will be essential when multiple agents compete for a shared context pool.

---

*Previous: [Chapter 2 — Agentic Workflows](./ch2-plan-and-execute.md)*

*Next: [Chapter 4 — AI-Driven Development](./ch4-ai-driven-development.md)*