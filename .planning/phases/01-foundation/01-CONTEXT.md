# Phase 1: Foundation - Context

**Gathered:** 2026-06-06
**Status:** Ready for planning

## Phase Boundary

Polish Chapter 1 to production-ready state; configure MkDocs for local development with `mkdocs build --strict` and `mkdocs serve` working correctly.

## Implementation Decisions

### Directory Layout
- **D-01:** `docs/` directory at `book/` root is the MkDocs source root (standard MkDocs convention)
- **D-02:** Chapter files live in `book/docs/` — e.g., `book/docs/ch1-ai-supported-software.md`
- **D-03:** Chapter filename: `ch1-ai-supported-software.md` (SEO-friendly, matches planned naming convention for ch2, ch3, etc.)

### mkdocs.yml Configuration
- **D-04:** Add `docs_dir: book/docs` to `book/mkdocs.yml`
- **D-05:** Set `edit_url` to point to the GitHub repository for each chapter file (e.g., `https://github.com/yourusername/exploration-to-engineering/edit/main/book/docs/{path}`)
- **D-06:** Update `site_url` and `extra.homepage` from placeholder `yourusername` to actual values
- **D-07:** Navigation structure: Home (`index.md`) + Ch1 + future chapters — extend as more chapters are added

### Python Version Pinning
- **D-08:** Pin Python to `3.12` via `book/.python-version` — aligns with MkDocs 1.6.x requirements and Cloudflare Pages support

### Build & Local Development
- **D-09:** `mkdocs build --strict` must succeed with no warnings or errors — enforced in Phase 1
- **D-10:** `mkdocs serve` runs for live preview during development
- **D-11:** EPUB build (`book/build.sh`) will be updated in Phase 3; Phase 1 focuses on MkDocs build

### Deployment Preparation (Phase 2 scope)
- Phase 2 wires up GitHub Actions → Cloudflare Pages; Phase 1 ensures the local build is ready for that pipeline

### Claude's Discretion
- mkdocs.yml theme customization (colors, fonts, logo) — open to standard Material defaults for now
- Specific admonition types, code highlight styles — defer to Material defaults unless user specifies

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Configuration
- `book/mkdocs.yml` — current MkDocs config (needs `docs_dir`, `edit_url`, placeholder updates)
- `book/.python-version` — to be created with `3.12` (does not exist yet)

### Chapter Content
- `book/docs/ch1-ai-supported-software.md` — existing Ch1 content (18,572 bytes, already in docs/)
- `book/docs/index.md` — existing index page
- `book/docs/assets/` — existing assets directory

### Build Scripts
- `book/build.sh` — existing EPUB build script (references `docs/` path, will need updating)

### Planning
- `.planning/ROADMAP.md` — Phase 1 definition (goal, requirements, success criteria)
- `.planning/REQUIREMENTS.md` — Phase 1 requirements: CONTENT-01, CONTENT-02, CONTENT-03, BUILD-01, BUILD-03
- `.planning/PROJECT.md` — project scope and key decisions

</canonical_refs>

<codebase_context>
## Existing Code Insights

### Reusable Assets
- `book/docs/ch1-ai-supported-software.md` — existing chapter content, needs editorial polish
- `book/docs/index.md` — existing landing page
- `book/docs/assets/` — existing asset directory (CSS, images)

### Established Patterns
- MkDocs + Material theme already configured in `mkdocs.yml`
- `book/build.sh` uses Pandoc for EPUB export — confirmed working pattern

### Integration Points
- mkdocs.yml needs `docs_dir: book/docs` added — connects config to new docs/ location
- build.sh references `docs/` path — already aligns with new structure
- `.python-version` needed in `book/` directory for Phase 2 CI/CD (pins Python 3.12)

</codebase_context>

<specifics>
## Specific Ideas

- User wants `docs/` at `book/` root — standard MkDocs layout
- Ch1 filename: `ch1-ai-supported-software.md` (not the current `ai_supported_software_development_chapter.md` in `book/`)
- mkdocs.yml `edit_url` should follow: `https://github.com/{org}/{repo}/edit/main/book/docs/{path}`
- Python 3.12 pinned via `.python-version` in `book/` directory
- Phase 2 handles GitHub Actions + Cloudflare Pages — Phase 1 is purely local validation

</specifics>

<deferred>
## Deferred Ideas

### Phase 2 (Pipeline)
- GitHub Actions workflow setup (`.github/workflows/deploy.yml`)
- Cloudflare Pages configuration and secrets
- `cloudflare/wrangler-action@v3` integration

### Phase 3 (Polish)
- EPUB build script finalization (`book/build.sh` update)
- Navigation tabs for all published chapters
- `mkdocs-material` theme customization (colors, logo)
- Custom domain with HTTPS

### Phase 4 (Ch2)
- Chapter 2 content and tutorial format
- Chapters 3+ outline

</deferred>

---

*Phase: 01-Foundation*
*Context gathered: 2026-06-06*