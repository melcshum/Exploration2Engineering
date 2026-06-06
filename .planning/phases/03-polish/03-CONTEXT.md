# Phase 3: Polish - Context

**Gathered:** 2026-06-06
**Status:** Ready for planning

## Phase Boundary

Site is production-ready — theme configured, navigation working, drafts excluded, EPUB export functional.

## Implementation Decisions

### Navigation Structure
- **D-01:** Top-level tabs — Home + Ch1 at launch, extensible to more chapters as they are added. Clean, book-like organization.
- **D-02:** `nav` configuration in `mkdocs.yml` lists chapters as top-level tab items (not nested under section headers).

### Theme Configuration
- **D-03:** Code copy button enabled — Material theme built-in feature, one-click copy for code blocks.
- **D-04:** Search and navigation built-in via Material theme — no extra configuration needed beyond `mkdocs.yml` theme declaration.

### Draft Exclusion
- **D-05:** `draft: true` frontmatter in each draft chapter's markdown file — MkDocs excludes automatically from production build.
- **D-06:** Published chapters do NOT have `draft: true` — only draft chapters get the flag.

### edit_url
- **D-07:** `edit_url` pattern confirmed from Phase 1: `https://github.com/{org}/{repo}/edit/main/book/docs/{path}` — applied to all chapter files.

### EPUB Export
- **D-08:** Minimal viable EPUB — content readable, chapters separated, code blocks present. Plain styling acceptable.
- **D-09:** `book/build.sh` updated to produce working EPUB. Pandoc-based approach (already exists in build.sh) sufficient for minimal viable output.

### What Phase 3 Does NOT Cover
- Phase 2 already covers: GitHub Actions → Cloudflare Pages deployment
- Phase 4 covers: Chapter 2 content, chapters 3+ outline
- Future phase (v2): Custom domain with HTTPS, professional EPUB styling for Amazon KDP

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Configuration
- `book/mkdocs.yml` — needs nav configuration for tabs, code copy button, edit_url updates
- `book/build.sh` — existing EPUB build script (Pandoc-based, needs update for minimal viable output)
- `book/docs/` — chapter files with frontmatter (draft: true flags to be added)

### Prior Phase Context
- `.planning/phases/01-foundation/01-CONTEXT.md` — Phase 1 decisions
- `.planning/phases/02-pipeline/02-CONTEXT.md` — Phase 2 decisions (deployment)
- `.planning/ROADMAP.md` — Phase 3 definition (goal, requirements, success criteria)
- `.planning/REQUIREMENTS.md` — Phase 3 requirements: SITE-02, SITE-03, SITE-04, SITE-05, BUILD-02

</canonical_refs>

<codebase_context>
## Existing Code Insights

### From Phase 1 & 2
- mkdocs.yml at book/ root already has Material theme configured
- Phase 1 decided docs_dir: book/docs, chapter filename convention
- Phase 2 covers CI/CD pipeline — Phase 3 focuses on site quality
- build.sh uses Pandoc for EPUB — confirmed working pattern

### Integration Points
- nav: in mkdocs.yml controls tab structure
- theme: settings control code copy button and search
- frontmatter: draft: true on chapter files controls draft exclusion
- build.sh: needs update to ensure EPUB produces readable output

</codebase_context>

<specifics>
## Specific Ideas

- User wants top-level tabs navigation (Home + Ch1, extensible)
- User wants draft: true frontmatter for draft exclusion
- User confirmed edit_url pattern from Phase 1
- User wants minimal viable EPUB — readable, chapters separated, code blocks present, plain styling OK
- User wants code copy button enabled — built-in Material feature

</specifics>

<deferred>
## Deferred Ideas

### Phase 4 (Ch2)
- Chapter 2 content and tutorial format
- Chapters 3+ outline

### Future (v2)
- Custom domain with HTTPS (SITE-06)
- Professional EPUB styling for Amazon KDP (SITE-07)
- Community forum or Discord (CONTENT-07)
- Auto-graded exercises (CONTENT-06)

</deferred>

---
*Phase: 03-Polish*
*Context gathered: 2026-06-06*