# What is an Agentic Design Pattern?

## Scope

Before you can choose a pattern, you need to understand what it means for a system to be *agentic* — and why the design pattern you choose matters more than the model you use. This chapter introduces the concept of agentic design patterns as a vocabulary for building AI systems that act, decide, and adapt.

---

## Learning Objectives

By the end of this chapter, you should be able to:

- Define what makes a system "agentic" versus merely "prompted."
- Explain why agentic design patterns matter — and why the pattern matters more than the model.
- Identify the four properties every agent has: perception, reasoning, action, and memory.
- Describe the difference between a single-agent system and a multi-agent system.
- Understand when to use each of the six patterns — and when NOT to use a multi-agent design.
- Use this chapter as a map to the detailed pattern catalog in Chapter 8.

---

## What Makes a System Agentic?

An AI system is *agentic* when it takes actions in the world — not just generating text, but doing things. An agentic system:

- **Perceives** its environment (receives input, reads files, calls APIs, gets tool results)
- **Reasons** about what to do next (uses an LLM to decide)
- **Acts** (calls tools, writes output, invokes other agents)
- **Remembers** (stores state across turns — conversation history, scratchpad, persistent memory)

A chatbot that answers questions? That's prompted, not agentic. A system that answers questions AND searches the web, writes files, runs code, and updates a database? That's agentic.

The line between "prompted" and "agentic" is action. When the AI system does something that affects the world beyond generating text, it has crossed into agentic territory.

---

## Why Design Patterns Matter More Than the Model

Teams building AI applications often ask: *"Which model should we use?"*

The better question is: *"Which design pattern should we use?"*

A GPT-4 model in a poorly designed single-agent loop will underperform a Claude Haiku with a well-designed multi-agent architecture. The model is the engine. The design pattern is the chassis. A better engine in the wrong chassis goes nowhere.

Consider:

- **Single Agent with a great prompt** beats **Multi-agent pipeline with bad routing**
- **Parallel agents with clear, independent tasks** beat **Sequential pipeline where every agent waits for the last**
- **Router with an accurate classifier** beats **Fallback to a general agent that guesses**

The pattern you choose determines:
- How reliable the system is under load
- How easy it is to debug when something goes wrong
- How the system scales as you add capabilities
- How much it costs to run

---

## The Six Patterns at a Glance

| Pattern | What it is | Use when... |
|---------|------------|--------------|
| **Single Agent** | One agent does everything | Simple task, clear path, prototyping |
| **Sequential Agents** | Agents in a pipeline, each passes to the next | Distinct phases must happen in order |
| **Parallel Agents** | Multiple agents work simultaneously | Independent subtasks, speed matters |
| **Review & Critique** | One agent generates, another reviews, they iterate | Quality matters more than speed |
| **Routing Agent** | A classifier sends tasks to specialists | Distinct categories of tasks |
| **Agent-as-a-Tool** | One agent can invoke other agents as tools | Dynamic specialist delegation at runtime |

---

## When to Use Each

### Use a Single Agent when:
The task is straightforward, the path from input to output is clear, and the cost of adding coordination outweighs the benefit. Most prototypes start here.

### Use Sequential when:
You have distinct phases that must happen in order and you want clear checkpoints between them. Research → Write → Edit is a classic sequence.

### Use Parallel when:
You have independent subtasks that don't depend on each other's output. Three agents reviewing a document from three different angles — legal, technical, business — can all run at the same time.

### Use Review & Critique when:
You care about quality more than speed. Code, legal documents, strategic plans — anything where a second set of eyes materially improves the output.

### Use Routing when:
Your system handles distinct categories of requests that need different expertise. A support system that routes to billing vs. technical vs. general has clear categories.

### Use Agent-as-a-Tool when:
The calling agent needs to decide at runtime whether to invoke a specialist — and that decision depends on the content of the task itself.

---

## The Spectrum of Agentic Complexity

Think of these patterns as a complexity spectrum:

```
Simple → Complex
Single Agent
  ├── Sequential (adds ordering)
  │     └── Parallel (adds concurrency)
  │           └── Router (adds classification)
  │                 └── Review & Critique (adds iteration)
  │                       └── Agent-as-a-Tool (adds dynamic delegation)
```

More complexity is not always better. Move up the spectrum when:
- A simpler pattern is creating brittleness or quality problems
- You can clearly articulate why the added complexity solves a specific failure mode
- The cost of coordination is worth the benefit

Move down the spectrum when:
- The added coordination overhead is not justified by the problem
- You are prototyping and speed of iteration matters more than robustness
- Debugging is taking longer than building

---

## The Four Properties Every Agent Has

Understanding these four properties helps you debug any agentic system:

**1. Perception**
What does the agent see when it makes a decision? System prompt, user query, tool results, conversation history, retrieved documents — all of this is perception.

**2. Reasoning**
How does the agent decide what to do? The LLM inference step — "given what I see, what should I do next?"

**3. Action**
What can the agent do? Tool calls, sending messages to other agents, writing output, invoking sub-agents.

**4. Memory**
What persists across turns? Conversation history, compaction summaries, persistent storage, user preferences.

When an agentic system fails, it usually fails on one of these four. Fix perception with better context. Fix reasoning with better prompting. Fix action with better tools. Fix memory with better state management.

---

## The Context Engineering Connection

*(This connects to Chapter 7: Context Engineering.)*

Every agent's perception is a context engineering problem. What you pass into the agent's context window — at each step — determines what it can reason about and act on.

A single agent with good context engineering beats a multi-agent pipeline with poor context management. Before adding more agents, improve your context pipeline.

The patterns in this chapter do not replace context engineering. They supplement it. When context engineering alone can't solve the problem — when you need different expertise domains, quality gates, or dynamic routing — reach for a design pattern.

---

## A Practical Decision Framework

When you start a new AI feature, ask:

```
1. Is this task simple enough for one agent with good prompting?
   → Yes: Start with Single Agent.
   → No: Go to 2.

2. Does the task have distinct phases in a known order?
   → Yes: Sequential Agents.
   → No: Go to 3.

3. Can independent parts run at the same time?
   → Yes: Parallel Agents.
   → No: Go to 4.

4. Does quality matter more than speed?
   → Yes: Add Review & Critique loop.
   → No: Go to 5.

5. Do tasks fall into distinct categories?
   → Yes: Routing Agent.
   → No: Go to 6.

6. Do you need dynamic specialist delegation at runtime?
   → Yes: Agent-as-a-Tool.
   → No: Go back to step 1 — you may not need a multi-agent design.
```

---

## Where to Go Next

This chapter gave you the vocabulary. Chapter 8 gives you the catalog — each pattern in depth, with code, tradeoffs, and labs.

Start with this chapter to understand what you need. Then go to Chapter 8 to implement it.

---

## Review & Discussion

1. You are building a coding assistant that writes, reviews, and tests code. Why might you start with a Single Agent before moving to a multi-agent design?

2. A colleague says: "Our system is agentic because it uses an LLM." What is wrong with this definition, and how would you correct it?

3. When is the added complexity of a multi-agent design WORTH the coordination overhead? Give a specific example.

4. The chapter says "fix perception with better context." In your own words, what does that mean — and why is it usually the first thing to check when an agent is failing?

---

*Design patterns are the vocabulary of professional AI systems. Learn them all, and you'll see problems differently. You'll stop asking "what should I prompt?" and start asking "what architecture does this problem actually need?"*
