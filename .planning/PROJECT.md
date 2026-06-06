# From Exploration to Engineering

## What This Is

A practical textbook teaching college students to build AI-supported software. Each chapter drives a complete, deployable project — students learn by building real applications, not just reading concepts. Deployment pipeline: GitHub Actions → Cloudflare Pages.

## Core Value

Students who finish this book can confidently build and deploy AI-supported applications using modern LLM, RAG, and agentic workflow patterns — ready for internships or entry-level roles.

## Target Audience

- **Primary**: College students in CS/SWE programs (freshman-senior)
- **Prerequisites**: Basic programming (Python preferred), Git familiarity, command-line comfort
- **Assumed context**: No prior AI/ML experience required; book is self-contained

## Audience Problem

College CS curricula rarely cover AI-assisted development tools, leaving graduates unprepared for internships and entry-level roles that expect AI tool fluency. Existing AI resources are either too shallow (tool tutorials) or too academic (research papers). Students need a practical bridge from "I know programming" to "I can build AI-supported software."

## Scope

**In Scope:**
- Tutorial-format chapters, each culminating in a deployable project
- MkDocs + Material theme for the book site
- GitHub Actions → Cloudflare Pages CI/CD pipeline
- LLM integration patterns (prompting, tool use, safety guardrails)
- RAG fundamentals and practical implementation
- Agentic workflow design (task decomposition, loops, memory)
- Code examples in Python with executable snippets
- Deployment patterns for Cloudflare Pages

**Out of Scope:**
- Deep ML/AI theory (backpropagation, training, fine-tuning)
- Non-Python language examples
- Enterprise authentication patterns (OAuth, SAML)
- Multi-cloud deployments beyond Cloudflare
- Academic exercises with grading rubrics

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Tutorial format | Project-driven learning keeps students engaged; faster time-to-build | — Pending |
| GitHub Actions → Cloudflare Pages | Free, fast, developer-friendly; natural fit for open-source books | — Pending |
| Python-first | Dominant language for AI tooling; largest student familiarity | — Pending |
| Ch1 draft needs polish | Content foundation exists, needs editorial pass | — Pending |
| Multi-chapter, not fixed number | Scope will grow with student feedback | — Pending |

## Requirements

### Active

- [ ] **BOOK-01**: Tutorial format — each chapter builds one complete, deployable project
- [ ] **BOOK-02**: Ch1 polished and production-ready on the deployed site
- [ ] **BOOK-03**: GitHub Actions CI/CD pipeline that builds and deploys to Cloudflare Pages
- [ ] **BOOK-04**: Cloudflare Pages deployment live at a shareable URL
- [ ] **BOOK-05**: Ch2 drafted and aligned with tutorial format
- [ ] **BOOK-06**: Ch3+ outlined with sufficient depth for multi-chapter curriculum

### Out of Scope

- Academic grading rubrics — this is a self-study resource, not a for-credit course
- Non-Python code examples — Python is the primary language; other languages deferred
- Video content — written format only at launch

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-06 after initialization*