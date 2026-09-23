# Chapter 2: Agentic Workflows — From Prompt Experiments to Autonomous Task Execution

## Scope

This chapter builds directly on the conceptual foundations established in Chapter 1. Where Chapter 1 introduced the separation of compute and context, the limitations of next-token prediction, and the RAG architectural pattern, this chapter addresses a more demanding question: how do we build software systems where an AI agent does not merely answer a single question, but **plans a sequence of actions, executes them in order, observes their results, and adapts its approach** when the plan fails?

We cover four interconnected topics:

1. **Why single-step AI interactions are insufficient** — the gap between "ask and answer" and "plan, act, observe, adapt."
2. **The Plan-and-Execute architectural pattern** — how separating planning from execution enables fault-tolerant, multi-step AI workflows.
3. **State management in agentic systems** — how agents track their own progress, handle partial failures, and maintain coherent context across steps.
4. **From script to system** — the transformation from a brittle Python script that calls an LLM once to a robust agentic pipeline with explicit state, typed components, and testable behaviour.

This chapter focuses on the **Plan-and-Execute** pattern specifically. It does not cover multi-agent orchestration (Chapter 8), context window optimization (Chapter 7), or production deployment and guardrails (Chapter 5).

---

## Learning Objectives

By the end of this chapter, students should be able to:

- Explain why single-step LLM interactions are insufficient for complex, multi-step tasks and describe the failure modes they produce.
- Design and implement a Plan-and-Execute agentic workflow in Python with separated Planner and Executor components.
- Identify and manage the key state variables that an agentic system must track across multiple reasoning steps.
- Evaluate whether a given task is better suited to a single-agent pipeline or a Plan-and-Execute architecture.
- Trace how context and data move through an agentic system and predict where failures are most likely to occur.

---

## Lead-In: The Limits of Single-Turn Intelligence

Chapter 1 introduced the core mental model for AI-supported software: a system that separates the **compute** of a foundation model from the **context** of an external knowledge base, using retrieval-augmented generation to ground responses in verified information. That architecture is powerful for question-answering tasks — "What is a for loop?", "What does RFC 7231 say about cache control?" — but it assumes a single, self-contained interaction. The user asks a question. The system retrieves relevant context, builds a prompt, and returns a grounded response. Case closed.

Real software does not work this way.

Consider a task that is only slightly more complex than a single question: "Help me refactor this Python function to use a generator instead of a list comprehension, then write a unit test for it." This is not one question. It is a sequence of subtasks, each dependent on the output of the previous one. The agent must first understand the existing function, then produce a semantically equivalent generator-based version, then write a test that validates the refactored code. Each step requires the agent to hold the output of the prior step in its context while reasoning about the next.

Now consider a task that is even more demanding: "Review the pull request, identify any security issues, check that the tests cover the new code paths, and if there are gaps, suggest specific additional tests." This requires the agent to perform multiple distinct operations — code review, security analysis, test coverage assessment — and potentially loop back: if the security review finds issues, the agent must return to the code and propose fixes before proceeding to the test assessment.

These are the tasks that Chapter 1's architecture cannot reliably solve. The RAG pipeline from Chapter 1 is a **single-step, feed-forward** architecture: input goes in, retrieval happens, generation happens, output comes out. There is no mechanism for the system to try something, observe whether it worked, revise its approach, and try again. There is no explicit tracking of what steps have been completed, what the intermediate results were, or what should happen if a step fails.

This is the gap that agentic workflows fill. An agentic system is one in which the AI is not merely consulted for a response, but is **given agency** — the ability to take actions, observe their results, and use that observation to decide what to do next. The word *agency* is chosen carefully here. An agent does not just generate text. It generates **intended actions**, executes them (or delegates execution to a tool), and reasons about the observed outcomes before proceeding.

The transition from single-step RAG to agentic workflows is the transition from a **reactive** system to a **proactive** one. Reactive systems answer questions. Proactive systems solve problems. This chapter teaches you to build the latter.

---

## Why Single-Turn AI Interactions Break Down

### The Problem of Multi-Step Tasks

A single-turn interaction is one in which the LLM receives a prompt and produces a response, with no action taken between the two. Chapter 1's RAG pipeline is structurally a single-turn system: the user query enters, retrieval happens, the LLM generates a response, and the interaction ends. Even if the retrieval step queries a vector database, the overall flow is linear and non-looping.

This architecture works well when the task is **self-contained** — when the answer to the question can be produced entirely from the context available at query time. But many tasks are not self-contained. They require a sequence of steps where each step's input depends on the previous step's output.

The failure modes of single-turn systems are predictable and instructive:

**Error propagation without recovery.** If step one in a five-step task produces an incorrect output, and that output becomes the context for step two, then step two compounds the error. The system has no mechanism to detect the error at step one and backtrack. By step five, the output may be completely unrelated to the intended result, and the system has no awareness of this.

**Loss of intermediate state.** When a complex task is expressed as a single prompt, the LLM must internally track what it has done so far and what remains to be done. This is the LLM's own working memory — its attention over the context window. For tasks with many steps, this places a heavy burden on the model's ability to maintain coherent long-range attention. Models can and do lose track of subgoals, forget constraints established in earlier steps, or contradict themselves across a long interaction.

**No action capacity.** A single-turn system cannot call a tool, write a file, execute code, or interact with an external API. It can only generate text. This means that any task requiring the AI to produce a lasting artifact — a file written to disk, a database updated, a message sent — must be handled outside the LLM's execution loop. In a single-turn architecture, these external actions are the responsibility of the calling application, not the AI itself.

**Rigid execution order.** Single-turn systems execute in one pass. They cannot conditionally skip steps, retry failed steps, or dispatch parallel subtasks. A task that requires branching logic — "if the retrieved document says X, do A; otherwise do B" — cannot be expressed cleanly in a single prompt without the LLM simulating the branching logic internally, which it often does unreliably.

Understanding these failure modes is not merely academic. When you design an AI-supported system, the failure mode determines the architecture. A task that decomposes naturally into independent subtasks might be well-served by a parallel pipeline. A task with strict dependencies between steps requires a sequential pipeline. A task with uncertain outcomes at each step requires the agentic loop: act, observe, decide.

### The Cognitive Load Problem

There is a second, subtler reason single-turn systems struggle with complex tasks: **cognitive load on the LLM itself**. When you ask a model to solve a five-step problem in a single prompt, you are asking it to simultaneously maintain the following in its context window:

- The original task description and any constraints
- All intermediate reasoning for each of the five steps
- The goals and success criteria for each step
- Any retrieved context relevant to each step
- The relationships between steps (what feeds into what)
- The final output format and quality bar

This is a substantial burden. Even with large context windows, the model's ability to reason accurately degrades as the number of simultaneous subgoals increases. This is not a hypothetical: studies of LLM performance on multi-step reasoning tasks consistently show that error rates increase as the number of steps grows, even when the individual steps are simple.

The agentic solution to cognitive overload is **step decomposition**. Instead of asking the model to hold all steps in mind simultaneously, we ask it to plan the steps first, then execute them one at a time. At each step, the model needs to reason about only one action, its inputs, and its expected outputs. This dramatically reduces the contextual burden on any single inference call.

This decomposition is the core insight behind the Plan-and-Execute pattern.

---

## The Plan-and-Execute Architectural Pattern

### Conceptual Architecture

The Plan-and-Execute pattern is deceptively simple: separate the **planning** of a task sequence from the **execution** of each step. The system asks the LLM to produce a plan — a structured list of steps to accomplish the goal — and then executes those steps one by one, observing the result of each before proceeding to the next. If a step fails, the system can replan from the current state rather than starting over.

This separation of concerns is the pattern's defining feature and its primary source of power. By decoupling *what to do* from *how to do it*, the system gains three critical properties:

**Reversibility.** When execution fails at step three, the Planner can replan from the current state (after steps one and two completed successfully) without losing the work already done. A monolithic single-turn approach would have to restart the entire task.

**Auditability.** Because the plan is explicit and the execution log records each step's inputs and outputs, the system's behaviour is traceable. You can inspect why step three failed, what input it received, and what the expected output was. This is essential for debugging and for building user trust.

**Parallelism.** The Planner can sometimes produce a plan with steps that are independent of each other — steps that can be executed concurrently. The Executor can dispatch these parallel steps simultaneously, reducing end-to-end latency.

### The Three-Component Model

A Plan-and-Execute system is built from three loosely coupled components, each with a distinct responsibility:

**The Planner.** The Planner receives a task description and produces a structured plan. The plan is a sequence of named steps, each describing an action and its expected outcome. The Planner does not execute the steps — it only thinks about *what to do*. This separation is critical: the Planner's job is reasoning, not doing.

**The Executor.** The Executor receives one step at a time from the plan and carries it out. The Executor may call tools (a code interpreter, a web search, a file write operation), query a RAG system, or delegate to a specialized sub-agent. The Executor returns a structured result: whether the step succeeded, what output it produced, and any error or observation worth noting.

**The State Manager.** The State Manager tracks the system's current state across all steps. It records which steps have been completed, what each step produced, what the current step is, and any errors encountered. The State Manager is the connective tissue that allows the system to replan intelligently when a failure occurs.

> **Key Definition — Plan-and-Execute:** A multi-step agentic pattern in which a Planner component produces an explicit, ordered sequence of steps from a task description, an Executor component carries out each step sequentially while recording results, and a State Manager tracks progress and enables intelligent replanning when failures occur. The pattern is distinct from a single-agent loop in that planning and execution are separated into distinct stages, not interleaved.

### Data Flow in Plan-and-Execute

Understanding how data moves through a Plan-and-Execute system is essential for designing, debugging, and extending it. Consider a concrete task: "Refactor the `calculate_total` function in `orders.py` to use a generator, then write tests for it."

The data flow through the system proceeds as follows:

```
Task Description
       │
       ▼
┌─────────────┐
│   Planner   │  ← Receives task description + current state
│  (LLM call) │
└──────┬──────┘
       │ Plan: [Step 1: Read file, Step 2: Refactor to generator,
       │        Step 3: Write refactored file, Step 4: Write tests]
       ▼
┌─────────────┐
│   Executor  │  ← Receives Step 1: "Read the contents of orders.py"
│  (Tool call)│
└──────┬──────┘
       │ Observation: File contents retrieved (or error)
       ▼
┌─────────────┐
│State Manager│  ← Records Step 1 result, updates current step to Step 2
│ │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Executor  │  ← Receives Step 2: "Refactor to use a generator"
│  (LLM call) │ Input: original file contents + refactoring instruction
└──────┬──────┘
       │ Observation: Refactored code (or error)
       ▼
┌─────────────┐
│State Manager│  ← Records Step 2 result
│             │
└──────┬──────┘
       │
       ▼
    ... (continues for each step)
```

The State Manager is queried at each decision point. Before the Executor proceeds to a new step, it checks the State Manager: has this step already been attempted? What was the result? Is the system in a state where the next step can safely proceed?

### High-Level System Structure (Pseudo-Code)

The following pseudo-code illustrates the structure of a Plan-and-Execute system without committing to a specific deployment language. This is the **architectural skeleton** that the coding lab later populates with working Python.

```text
class PlanAndExecuteAgent:
    planner: Planner
    executor: Executor
    state: StateManager

    def solve(task: str) -> ExecutionResult:
        # Phase 1: Plan
        plan = planner.create_plan(task, state.get_context())

        # Phase 2: Execute
        for step in plan.steps:
            result = executor.execute(step, state.get_context())

            state.record_step(step.id, result)

            if result.status == FAILED:
                # Replan from current state, do not restart from task
                plan = planner.replan(task, state.get_context())
                break  # restart loop with new plan

            if result.status == COMPLETED:
                continue  # proceed to next step

        return state.build_final_result()
```

Note the critical detail in the replanning branch: `planner.replan(task, state.get_context())` passes the **current state**, not just the original task. This means the new plan knows what steps already succeeded and can avoid repeating them. This is what distinguishes Plan-and-Execute from a simple retry loop.

---

## Excalidraw Visual Specification: Plan-and-Execute Agent Architecture

Create an Excalidraw diagram with the following structure:

**Canvas size:** 1200 × 700 px

**Boundary containers (use rounded rectangles, dashed stroke, light fill):**

- A large dashed boundary labeled **"Plan-and-Execute Agentic System"** enclosing all components. Fill: `#f0f4ff`, stroke: `#4a6fa5`, stroke width: 2, dash pattern: 84.

- Inside the main boundary, two nested regions:
  - **Left region** labeled **"Planning Phase"** — fill: `#e8f5e9`, stroke: `#2e7d32`, rounded corners.
  - **Right region** labeled **"Execution Phase"** — fill: `#fff3e0`, stroke: `#e65100`, rounded corners.

**Nodes (rectangles with rounded corners, solid fill):**

- In the Planning Phase region:
  - **"Task Description"** — fill: `#e3f2fd`, stroke: `#1565c0`, size: 160 × 50, text: bold.
  - **"Planner (LLM)"** — fill: `#c8e6c9`, stroke: `#2e7d32`, size: 180 × 60, text: bold.
  - **"Plan Document"** — fill: `#f1f8e9`, stroke: `#558b2f`, size: 180 × 60, text: italic.

- In the Execution Phase region:
  - **"Executor (Step N)"** — fill: `#ffe0b2`, stroke: `#e65100`, size: 180 × 60, text: bold.
  - **"Tool: Code Interpreter"** — fill: `#fce4ec`, stroke: `#c2185b`, size: 180 × 50.
  - **"Tool: File System"** — fill: `#fce4ec`, stroke: `#c2185b`, size: 180 × 50.
  - **"Tool: RAG Retrieval"** — fill: `#fce4ec`, stroke: `#c2185b`, size: 180 × 50.
  - **"Step Result + Observation"** — fill: `#fff8e1`, stroke: `#f9a825`, size: 200 × 60, text: italic.

- In the center, spanning both phases:
  - **"State Manager"** — fill: `#ede7f6`, stroke: `#4527a0`, size: 200 × 80, text: bold, font size: 14. This node is the focal point — draw it centrally between the two phases.

**Directed edges (solid arrows with labels):**

- Task Description → Planner (LLM) — label: "1. Input task"
- Planner (LLM) → Plan Document — label: "2. Generate plan", arrow: solid, color: `#2e7d32`
- Plan Document → State Manager — label: "3. Store plan", arrow: dashed, color: `#4527a0`
- State Manager → Executor (Step N) — label: "4. Next step + context", arrow: solid, color: `#e65100`
- Executor (Step N) → Tool nodes — label: "5. Execute action", arrow: dashed, color: `#e65100`
- Tool nodes → Step Result — label: "6. Observation", arrow: solid, color: `#f9a825`
- Step Result + Observation → State Manager — label: "7. Record result", arrow: solid, color: `#4527a0`
- State Manager → Planner (LLM) — label: "8. Replan (if failed)", arrow: dashed, color: `#c62828`, curved

**Labels:**
- Add a small label in the top-right corner of the Planning Phase region: **"Reasoning only — no side effects"**
- Add a small label in the top-right corner of the Execution Phase region: **"Actions, tool calls, state changes"**
- Add a note near the State Manager: **"Tracks: plan, completed steps, step results, current step, errors"**

---

## State Management in Agentic Systems

### What State an Agent Must Track

State management is the discipline that separates a reliable agentic system from a brittle script. Every agentic system — regardless of whether it uses Plan-and-Execute, a single-agent loop, or multi-agent orchestration — must maintain some form of state. The specific state variables depend on the task and architecture, but the core requirements are universal.

**The Plan.** The sequence of steps the Planner has determined will accomplish the task. This plan may be modified during execution if a step fails or if new information changes the Planner's understanding of the problem.

**Completed Steps.** Which steps have been executed, in what order, and what each step produced. This is essential for two reasons: it prevents the Executor from re-running steps that have already succeeded, and it provides the context for intelligent replanning when a failure occurs.

**Current Step.** Which step the system is actively processing. The current step is the primary determinant of what action the Executor takes next.

**Step Results.** The observed output of each completed step. These results serve two purposes: they provide the input context for subsequent steps (step three may need the output of step two), and they serve as an audit trail for debugging when something goes wrong.

**Error Log.** Any failures, exceptions, or unexpected observations that occurred during execution. The error log is read by the Planner when deciding whether to replan and how to adjust the remaining steps.

**Session Context.** Any prior conversation history, user preferences, or task constraints that the system has learned during the session. In a longer-running agentic system, this prevents the agent from asking the user the same clarifying questions repeatedly.

### State as a First-Class Object

In an object-oriented design, state should be a **first-class object** — a typed data structure with clear fields, not a collection of global variables or an implicit property of the agent. This makes the system testable, auditable, and extensible.

Consider the difference between these two approaches to state:

**Approach A — Implicit state (brittle):**

```python
# State is implicit: scattered across function arguments, globals, and return values
def planner(task):
    return plan # plan is a list, but its structure is undocumented

def executor(step):
    return result  # result is a dict with inconsistent field names
```

**Approach B — Explicit state (robust):**

```python
from dataclasses import dataclass, field
from typing import Literal

@dataclass
class StepResult:
    step_id: str
    status: Literal["pending", "completed", "failed"]
    output: str | None = None
    error: str | None = None
    timestamp: str | None = None

@dataclass
class AgentState:
    task: str
    plan: list[str] = field(default_factory=list)
    completed_steps: dict[str, StepResult] = field(default_factory=dict)
    current_step_index: int = 0
    error_log: list[str] = field(default_factory=list)
    session_context: dict = field(default_factory=dict)

    @property
    def current_step(self) -> str | None:
        if self.current_step_index < len(self.plan):
            return self.plan[self.current_step_index]
        return None

    @property
    def is_complete(self) -> bool:
        return self.current_step_index >= len(self.plan)
```

Approach B makes the state explicit, typed, and inspectable. You can write unit tests that create an `AgentState`, simulate a step being completed, and verify that `current_step_index` advances correctly. You can serialize the state to JSON for audit logging. You can snapshot the state before a risky operation and restore it if the operation fails.

This is the level of engineering discipline that separates a **research prototype** from a **production system**. Chapter 1's RAG pipeline, built as a single Python script that chains a retriever to a prompt builder to an LLM call, is a prototype. A Plan-and-Execute agent with explicit typed state management is a production-ready design.

### The ROADMAP.md and STATE.md Parallel

Students who have worked with project planning tools will recognize the structure we are using here. The **ROADMAP.md** file in this project defines the high-level phases and their success criteria — much like the `plan` in a Plan-and-Execute agent. The **STATE.md** file tracks current progress, completed phases, and active blockers — much like the `AgentState` tracks completed steps, the current step, and the error log.

This is not a coincidence. The same principles that make project management effective — explicit tracking of what is done, what is in progress, what failed and why — make agentic state management effective. When the Planner produces a plan, it is creating a ROADMAP for the agent's task. When the State Manager updates progress after each step, it is updating a STATE file for the agent's execution.

Understanding this parallel will help you design better agentic systems. Every time you add a state variable to the agent, ask yourself: does this variable represent something that would appear in a project management plan or status file? If yes, the variable is likely necessary and well-motivated. If no, you may be over-engineering the state tracking at the expense of the actual task.

---

## Excalidraw Visual Specification: State Data Flow

Create an Excalidraw diagram focused on the State Manager's role:

**Canvas size:** 900 × 600 px

**Central node:**

- **"State Manager"** — large rounded rectangle, fill: `#ede7f6`, stroke: `#4527a0`, stroke width: 3, size: 220 × 90, centered on canvas, text: bold, font size: 16.

**Input arrows (left side):**

- From **"Planner (LLM)"** — labeled **"Plan document"**, arrow into State Manager, color: `#2e7d32`.
- From **"Executor (Step N)"** — labeled **"Step N result + observation"**, arrow into State Manager, color: `#e65100`.

**Output arrows (right side):**

- From State Manager to **"Executor (Step N+1)"** — labeled **"Step N+1 + context (updated state)"**, arrow from State Manager, color: `#e65100`.
- From State Manager to **"Planner (LLM)"** — labeled **"State snapshot (for replanning)"**, dashed arrow, color: `#c62828`.

**State fields (inside the State Manager node, listed vertically):**

- `task: str`
- `plan: List[str]`
- `completed_steps: Dict[str, StepResult]`
- `current_step_index: int`
- `error_log: List[str]`
- `session_context: Dict`

**Legend box (bottom-left corner):**

- Small rounded rectangle, fill: `#f5f5f5`, stroke: `#9e9e9e`, with text:
  - Solid arrows: data flow
  - Dashed arrows: control flow (replan signal)
  - Color green: planning phase
  - Color orange: execution phase
  - Color red: error / replan signal

---

## From Script to System: A Worked Transformation

### The Starting Point: A Brittle Script

Consider a Python script that attempts the task from earlier: "Refactor the `calculate_total` function to use a generator, then write tests for it." A naive implementation might look like this:

```python
import openai
from pathlib import Path

client = openai.OpenAI()

def refactor_function(file_path: str, function_name: str) -> str:
    """Refactor a function to use a generator."""
    source = Path(file_path).read_text()

    prompt = f"""
    Read the following Python code from {file_path}.
    Refactor the function named '{function_name}' to use a generator instead of a list.
    Return only the refactored function code.
    ```
    {source}
    ```
    """
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content


def write_tests(file_path: str, function_name: str) -> str:
    """Write unit tests for the refactored function."""
    source = Path(file_path).read_text()

    prompt = f"""
    Write pytest unit tests for the generator version of the function '{function_name}'
    in the following code. Return only the test code.
    ```
    {source}
    ```
    """
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content


# Main execution
refactored = refactor_function("orders.py", "calculate_total")
Path("orders_gen.py").write_text(refactored)
tests = write_tests("orders_gen.py", "calculate_total")
Path("test_orders_gen.py").write_text(tests)
```

This script works for the happy path. It breaks in the following ways:

- If `refactor_function` returns code with a syntax error, the script writes the bad code to disk and then `write_tests` reads the bad code and writes tests for the broken version.
- If the LLM does not correctly identify which function to refactor, there is no mechanism to correct the mistake before writing.
- There is no logging of what the LLM was asked, what it returned, or whether the operation succeeded.
- If the API call fails, the script crashes with no recovery.
- There is no way to run just the refactoring step without the test-writing step.

### Transformation Step 1: Introduce Typed State

The first transformation introduces an explicit `RefactorState` dataclass:

```python
from dataclasses import dataclass, field
from typing import Literal, Optional
from datetime import datetime

@dataclass
class StepRecord:
    step_name: str
    status: Literal["pending", "completed", "failed"]
    input_data: str = ""
    output_data: str = ""
    error_message: Optional[str] = None
    timestamp: str = ""

@dataclass
class RefactorState:
    original_file: str
    function_name: str
    plan: list[str] = field(default_factory=list)
    steps: dict[str, StepRecord] = field(default_factory=dict)
    current_step: str = "read_source"
    error_log: list[str] = field(default_factory=list)

    def record_step(self, name: str, record: StepRecord) -> None:
        self.steps[name] = record
        if record.status == "failed":
            self.error_log.append(
                f"[{record.timestamp}] {name}: {record.error_message}"
            )

state = RefactorState(original_file="orders.py", function_name="calculate_total")
```

### Transformation Step 2: Separate Planner and Executor

The second transformation separates the planning logic from the execution logic:

```python
class Planner:
    def create_plan(self, task: str, state: RefactorState) -> list[str]:
        """Produce an ordered list of steps to accomplish the task."""
        # In production, this would call the LLM
        # For now, we use a hardcoded plan that matches the task structure
        return [
            "read_source",
            "refactor_to_generator",
            "validate_refactored_code",
            "write_refactored_file",
            "write_unit_tests",
        ]

    def replan(self, task: str, state: RefactorState) -> list[str]:
        """Create a revised plan after a step failure."""
        # The Planner receives the current state and decides how to adjust
        # the remaining steps. For example, if Step 3 (validate) failed,
        # the replan might add a "fix_syntax_error" step before retrying Step 2.
        failed_step = state.error_log[-1].split(":")[0] if state.error_log else "unknown"
        base_plan = self.create_plan(task, state)
        # In production: call LLM with state snapshot to generate adaptive replan
        return base_plan  # simplified for illustration


class Executor:
    def execute(self, step_name: str, state: RefactorState) -> StepRecord:
        step_handlers = {
            "read_source": self._read_source,
            "refactor_to_generator": self._refactor_to_generator,
            "validate_refactored_code": self._validate_code,
            "write_refactored_file": self._write_file,
            "write_unit_tests": self._write_tests,
        }
        handler = step_handlers.get(step_name)
        if not handler:
            return StepRecord(
                step_name=step_name,
                status="failed",
                error_message=f"No handler for step: {step_name}",
                timestamp=datetime.now().isoformat(),
            )
        return handler(state)

    def _read_source(self, state: RefactorState) -> StepRecord:
        # ... implementation
        pass
```

### Transformation Step 3: The Agent Orchestrator

The third transformation introduces the orchestrator that ties the components together:

```python
class RefactorAgent:
    def __init__(self, planner: Planner, executor: Executor):
        self.planner = planner
        self.executor = executor

    def solve(self, task: str) -> RefactorState:
        state = RefactorState(
            original_file="orders.py",
            function_name="calculate_total"
        )
        plan = self.planner.create_plan(task, state)
        state.plan = plan

        for step_name in plan:
            state.current_step = step_name
            result = self.executor.execute(step_name, state)
            state.record_step(step_name, result)

            if result.status == "failed":
                new_plan = self.planner.replan(task, state)
                remaining_steps = [
                    s for s in new_plan
                    if s not in state.steps or state.steps[s].status != "completed"
                ]
                state.plan = remaining_steps
                state.current_step = remaining_steps[0] if remaining_steps else "done"
                if state.current_step != "done":
                    continue
                break

        return state
```

This three-step transformation — from implicit to explicit state, from monolithic to separated components, from linear script to looping orchestrator — is the fundamental design pattern you will apply throughout this book. Each transformation adds a property: testability, auditability, and fault tolerance.

---

## Lead-Out: New Bottlenecks and the Path Forward

The Plan-and-Execute architecture described in this chapter solves the problems of multi-step task decomposition, explicit state tracking, and intelligent replanning. But it creates its own set of bottlenecks — new constraints that the next chapters address.

**The context window bottleneck.** Each step in a Plan-and-Execute agent passes its output to the next step via the State Manager. But the Planner and Executor both use an LLM, and each LLM call has a context window limit. As a plan grows in length or as step outputs become large (e.g., a 500-line refactored file that becomes the input to the test-writing step), the context window fills up. Chapter 7 addresses this directly: it covers **context engineering** — the discipline of selecting, compressing, and prioritizing what enters the LLM's context window at each step.

**The single-agent bottleneck.** This chapter's Plan-and-Execute system uses one Planner and one Executor. But what happens when the task requires fundamentally different kinds of reasoning — when, for example, the task requires both a security review and a performance analysis, and those analyses need to happen in parallel? A single-agent system cannot be in two places at once. Chapter 8 covers **multi-agent orchestration**: how to coordinate multiple agents, each specialized, working simultaneously on different aspects of a complex task.

**The tool interface bottleneck.** The Executor in this chapter executes steps by calling handler methods on itself. In a production system, you want the Executor to be able to call a wider variety of tools — web search, code execution, database queries, API calls — without changing the core architecture. Chapter 2's lab and extension work will touch on this, but Chapter 8's agent-as-a-tool pattern addresses it systematically.

**The evaluation bottleneck.** How do you know if the plan was a good plan? How do you measure whether the Executor correctly carried out the steps? Chapter 5 addresses evaluation and guardrails: how to build automated checks that verify the agent's outputs meet quality and safety standards before they are returned to the user.

The architecture is advancing. Each chapter adds capabilities while exposing new constraints. This is the nature of engineering — not a flaw to be eliminated, but a process to be embraced.

---

## Review & Discussion

1. **Explain the difference between a reactive AI system and a proactive AI system.** Use a concrete example from your own experience — a task you have tried to accomplish with an AI tool — to illustrate where a reactive system would fail and a proactive (agentic) system would succeed. What specific properties does the agentic system need that the reactive system lacks?

2. **The Plan-and-Execute pattern separates the Planner from the Executor.** What are the advantages of this separation? What would be lost if the Planner and Executor were merged into a single component that both planned and executed in the same loop? Consider this from the perspectives of fault tolerance, auditability, and cognitive load management.

3. **State management in agentic systems is often an afterthought.** Describe the failure modes that occur when state is managed implicitly rather than as a first-class typed object. In a system with implicit state, what information is lost that would be available in a system with explicit state management?

4. **The ROADMAP.md and STATE.md parallel was introduced as a framing device.** Do you find this parallel useful for understanding agentic state management? Identify one way the project management analogy helps, and one way you think it might mislead a developer who takes the analogy too literally. (Hint: think about the difference between human judgment in project management and the LLM's planning capabilities.)

5. **Consider the transformation from script to system described in the worked example.** Which of the three transformation steps — introducing typed state, separating Planner and Executor, introducing the orchestrator — do you believe contributed the most to the system's robustness? Defend your choice with specific reasoning about what failure modes it addresses.

---

## Conceptual Lab: Build a Plan-and-Execute Refactor Agent

In this lab, you will transform the brittle Python script from the chapter into a production-quality Plan-and-Execute agent. The lab is divided into four parts, each building on the previous one.

### Lab Setup

Create a new project directory:

```bash
mkdir ~/plan-execute-lab && cd ~/plan-execute-lab
pip install openai python-dotenv pathlib dataclasses
```

Create a `.env` file with your API key:

```
OPENAI_API_KEY=your_key_here
```

Create the source file to be refactored. In a real project, this would be provided by the user or extracted from a repository. For this lab, create `orders.py`:

```python
# orders.py — a simple module with functions to be refactored

def calculate_total(prices: list[float]) -> float:
    """Calculate the total of a list of prices."""
    result = 0
    for price in prices:
        result = result + price
    return result


def filter_expensive(items: list[dict], threshold: float) -> list[dict]:
    """Filter items whose price exceeds the threshold."""
    result = []
    for item in items:
        if item["price"] > threshold:
            result.append(item)
    return result
```

### Part 1 — Define Typed State

Create a file `state.py`. Define the following dataclasses:

- `StepRecord` — with fields: `step_id` (str), `status` (Literal["pending", "completed", "failed"]), `input_data` (str), `output_data` (str), `error` (str | None), `timestamp` (str).
- `AgentState` — with fields: `task` (str), `plan` (list[str]), `completed_steps` (dict[str, StepRecord]), `current_step_index` (int), `error_log` (list[str]).

Add a `__repr__` method to `AgentState` that returns a readable summary of the current state, including how many steps are completed, which step is current, and how many errors have been logged.

Add a method `is_complete(self) -> bool` that returns True when `current_step_index` is past the end of `plan`.

### Part 2 — Implement the Planner and Executor

Create a file `agent.py`. Implement three classes:

**`Planner`** — has a method `create_plan(task: str) -> list[str]` that returns a hardcoded plan:
```python
["read_source", "refactor_to_generator", "validate_code", "write_refactored_file", "write_tests"]
```

**`Executor`** — has a method `execute(step: str, state: AgentState, source_code: str) -> StepRecord`. The Executor should handle each step as follows:

- `read_source`: Returns a StepRecord with `status="completed"` and `output_data=source_code`.
- `refactor_to_generator`: Calls the OpenAI API (or a mock for testing) to refactor the `calculate_total` function to use a generator expression. Returns the refactored code as `output_data`.
- `validate_code`: Attempts to `compile()` the refactored code. If it succeeds, returns `status="completed"`. If it raises a `SyntaxError`, returns `status="failed"` with the error message.
- `write_refactored_file`: Writes the refactored code to `orders_gen.py` and returns `status="completed"`.
- `write_tests`: Calls the OpenAI API (or a mock) to generate pytest tests for the generator version and writes them to `test_orders_gen.py`. Returns `status="completed"`.

**`PlanAndExecuteAgent`** — combines a Planner and Executor:

```python
class PlanAndExecuteAgent:
    def __init__(self, planner: Planner, executor: Executor):
        self.planner = planner
        self.executor = executor

    def solve(self, task: str, source_code: str) -> AgentState:
        # Step 1: Create plan
        # Step 2: Initialize state
        # Step 3: Execute steps in order, recording results
        # Step 4: If a step fails, replan and continue
        # Step 5: Return final state
        pass  # implement this
```

### Part 3 — Run and Observe

Run the agent with the task: "Refactor the `calculate_total` function to use a generator expression."

```python
from agent import PlanAndExecuteAgent, Planner, Executor
from state import AgentState

planner = Planner()
executor = Executor()
agent = PlanAndExecuteAgent(planner, executor)

source_code = Path("orders.py").read_text()
task = "Refactor calculate_total to use a generator expression, then write tests."

final_state = agent.solve(task, source_code)
print(final_state)
```

Inspect the final state. Answer these questions:

- How many steps were in the plan?
- How many steps were completed successfully?
- Were any steps retried after failure?
- What was the content of `error_log` after execution?
- Were the output files (`orders_gen.py`, `test_orders_gen.py`) created correctly?

### Part 4 — Inject a Failure and Observe Replanning

Modify the Executor to intentionally produce a syntax error in the refactored code (for testing purposes). Run the agent again and observe:

- Does the agent detect the failure at the `validate_code` step?
- Does the `replan` method get called?
- What does the new plan look like?
- Does the agent eventually succeed, or does it fail again?

### Extension (if time allows)

Add a `MaxRetriesExceeded` exception that fires when a step has failed more than a configurable maximum (e.g., 3 times). Update the `PlanAndExecuteAgent.solve` method to catch this exception, record the final state, and return a result indicating that the task could not be completed within the retry budget. This is a simple but important production guardrail.

---

## Diagramming Exercise

Using **Mermaid** (or Excalidraw if your project supports it), produce a complete system diagram for the Plan-and-Execute Refactor Agent described in this chapter. Your diagram should include:

1. The three main components: Planner, Executor, State Manager.
2. The data flows between them, with directional arrows and labels.
3. The tools called by the Executor (file system, LLM API, code compiler).
4. The feedback loop from State Manager back to Planner for replanning.
5. The state fields inside the State Manager.

Use Mermaid `flowchart` syntax. Include a legend that explains the color coding of your arrows (e.g., green for planning-phase data flow, orange for execution-phase data flow, red for error/replan signals).

Then, in 2–3 paragraphs, write a brief architectural review: What does this diagram make obvious that the code alone does not? What does the code make obvious that the diagram alone does not? What would you add to the diagram to make it a more complete specification for a team of developers implementing this system?

---

## Summary

This chapter introduced the Plan-and-Execute architectural pattern as a structured solution to the multi-step task problem that single-turn AI interactions cannot solve. We examined why single-step systems fail when tasks decompose into dependent substeps — through error propagation without recovery, loss of intermediate state, and the cognitive burden placed on the LLM when asked to track many simultaneous goals.

The Plan-and-Execute pattern addresses these failures by separating planning from execution. The Planner produces an explicit, ordered sequence of steps. The Executor carries out each step, observing the result. The State Manager tracks progress across all steps, enabling intelligent replanning when failures occur. This separation gives the system reversibility (failed steps can be retried without restarting the entire task), auditability (every step's input and output is recorded), and the ability to distribute independent steps in parallel.

We transformed a brittle Python script into a production-quality agentic system in three stages: introducing typed state as a first-class object, separating Planner and Executor into distinct components, and introducing an orchestrator that manages the execution loop and handles replanning. Each stage added a property — testability, then auditability, then fault tolerance — that the previous stage lacked.

The architecture advanced significantly in this chapter. But it also created new bottlenecks: context window limits that constrain how much step output can be passed forward, a single-agent design that cannot parallelize fundamentally different reasoning tasks, and no automated evaluation of whether the agent's outputs are correct or safe. These are the topics of Chapters 5, 7, and 8 respectively.

---

*Previous: [Chapter 1 — AI-Supported Software Development](./ch1-ai-supported-software.md)*

*Next: [Chapter 3 — Model Integration and Context Management](./ch3-model-integration.md)*