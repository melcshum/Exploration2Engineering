# Phase 1: Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-06
**Phase:** 01-Foundation
**Areas discussed:** mkdocs.yml setup, deployment setup

---

## mkdocs.yml setup

| Option | Description | Selected |
|--------|-------------|----------|
| docs_dir: book/docs | Standard MkDocs layout, build pipeline uses mkdocs build | ✓ |
| mkdocs.yml at book/ root | Keep mkdocs.yml in book/ with default docs_dir: . Less standard | |

**User's choice:** docs_dir: book/docs (Recommended)
**Notes:** User wants the standard MkDocs convention with docs/ at book/ root.

---

## Ch1 filename

| Option | Description | Selected |
|--------|-------------|----------|
| ch1-ai-supported-software.md | Descriptive, SEO-friendly, matches other planned chapters | ✓ |
| Keep current name | ai_supported_software_development_chapter.md — keep or rename | |

**User's choice:** ch1-ai-supported-software.md
**Notes:** User wants the SEO-friendly naming convention that matches the planned ch2, ch3, etc.

---

## Deployment setup

| Option | Description | Selected |
|--------|-------------|----------|
| docs_dir: book/docs | Add docs_dir: book/docs to mkdocs.yml. Standard MkDocs layout | ✓ |
| mkdocs.yml at book/ root | Keep mkdocs.yml in book/ with default docs_dir | |

**User's choice:** docs_dir: book/docs (Recommended)
**Notes:** Standard MkDocs layout for Phase 1 local validation. Phase 2 handles GitHub Actions → Cloudflare Pages.

---

## Python version pinning

| Option | Description | Selected |
|--------|-------------|----------|
| 3.12 | Create book/.python-version with 3.12. Aligns with MkDocs 1.6+ requirements | ✓ |
| Let me specify | Create book/.python-version with version of your choice | |

**User's choice:** 3.12 (Recommended)
**Notes:** Pins Python 3.12 via book/.python-version for Phase 2 CI/CD compatibility.

---

## Claude's Discretion

- mkdocs.yml theme customization (colors, fonts, logo) — deferred to Material defaults
- Specific admonition types and code highlight styles — deferred to Material defaults
- EPUB build script details — Phase 3 scope

## Deferred Ideas

### Phase 2 (Pipeline)
- GitHub Actions workflow setup (`.github/workflows/deploy.yml`)
- Cloudflare Pages configuration and secrets
- `cloudflare/wrangler-action@v3` integration

### Phase 3 (Polish)
- EPUB build script finalization
- Navigation tabs for all published chapters
- Theme customization
- Custom domain with HTTPS

### Phase 4 (Ch2)
- Chapter 2 content and tutorial format
- Chapters 3+ outline