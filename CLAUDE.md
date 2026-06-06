

<!-- GSD:project-start source:PROJECT.md -->
## Project

**From Exploration to Engineering**

A practical textbook teaching college students to build AI-supported software. Each chapter drives a complete, deployable project — students learn by building real applications, not just reading concepts. Deployment pipeline: GitHub Actions → Cloudflare Pages.

**Core Value:** Students who finish this book can confidently build and deploy AI-supported applications using modern LLM, RAG, and agentic workflow patterns — ready for internships or entry-level roles.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Documentation Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **MkDocs** | 1.6.x | Static site generator | Proven, well-documented, Python-native; built-in `gh-deploy`; [official docs](https://www.mkdocs.org) confirm 1.6.x is current stable |
| **Material for MkDocs** | 9.7.x | Theme | Best-in-class documentation theme; search, navigation, code highlighting all built-in; [Context7 verified](https://github.com/squidfunk/mkdocs-material) |
| **Python** | 3.12 | Runtime | Latest stable Python; MkDocs requires 3.8+; Cloudflare Pages supports 3.11+ |
### CI/CD and Deployment
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **GitHub Actions** | — | CI/CD pipeline | Native to repo; free for open source; [Context7 verified](https://github.com/mkdocs/mkdocs/wiki/Mkdocs-Deployments) |
| **cloudflare/wrangler-action** | v3 | Deployment | [Official Cloudflare docs](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) recommend this over pages-action for flexibility |
| **actions/checkout** | v6 | Repository checkout | Latest major version; required for wrangler-action |
### Supporting Tools
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **pip-tools** | latest | Dependency locking | Generate reproducible `requirements.txt` |
| **mkdocs-material-extensions** | latest | Enhanced code features | If needing additional code annotation features beyond built-in |
## Project-Specific Configuration
# book/mkdocs.yml (current config is sound)
## GitHub Actions Workflow
# .github/workflows/deploy.yml
## Requirements File
# book/requirements.txt
## What NOT to Use and Why
| Technology | Why Avoid | Instead Use |
|------------|-----------|-------------|
| **Sphinx** | Steeper learning curve; more complex theming | MkDocs (simpler, Markdown-first) |
| **cloudflare/pages-action@v1** | Deprecated in favor of wrangler-action | `cloudflare/wrangler-action@v3` |
| **Python 3.7** | MkDocs 1.6+ requires 3.8+; Cloudflare Pages dropped support | Python 3.12 |
| **actions/checkout@v3/v4** | v6 has better performance and security | actions/checkout@v6 |
| **MkDocs Insiders (paid)** | Unnecessary unless requiring premium features | Open-source Material for MkDocs |
## Alternatives Considered
| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Documentation | MkDocs + Material | Sphinx + RTD theme | Sphinx has steeper learning curve; MkDocs is simpler for Markdown-heavy content |
| Deployment | Cloudflare Pages | GitHub Pages | Cloudflare has better global edge network; more generous free tier for static sites |
| CI/CD | GitHub Actions | Netlify CI | GitHub Actions is native to the repository; no additional service needed |
## Installation
# Local development
# Production build
## Sources
- [MkDocs Installation & Deployment](https://github.com/mkdocs/mkdocs/wiki/Mkdocs-Deployments) — Context7 verified
- [Material for MkDocs 9.x](https://github.com/squidfunk/mkdocs-material) — Context7 verified
- [Cloudflare Pages GitHub Actions](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) — Official docs
- [Cloudflare Pages Action](https://github.com/cloudflare/pages-action) — GitHub repo
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
