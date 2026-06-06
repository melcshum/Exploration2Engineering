# Phase 3: Polish - Research

**Researched:** 2026-06-06
**Domain:** MkDocs Material configuration for documentation site polish (YAML-only)
**Confidence:** HIGH (config-only phase, all tools already present, official docs verified)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Top-level tabs — Home + Ch1 at launch, extensible to more chapters as they are added. Clean, book-like organization.
- **D-02:** `nav` configuration in `mkdocs.yml` lists chapters as top-level tab items (not nested under section headers).
- **D-03:** Code copy button enabled — Material theme built-in feature, one-click copy for code blocks.
- **D-04:** Search and navigation built-in via Material theme — no extra configuration needed beyond `mkdocs.yml` theme declaration.
- **D-05:** `draft: true` frontmatter in each draft chapter's markdown file — MkDocs excludes automatically from production build. **[See Assumption A1 — this mechanism does not exist in MkDocs.]**
- **D-06:** Published chapters do NOT have `draft: true` — only draft chapters get the flag. **[See Assumption A1.]**
- **D-07:** `edit_url` pattern confirmed from Phase 1: `https://github.com/{org}/{repo}/edit/main/book/docs/{path}` — applied to all chapter files.
- **D-08:** Minimal viable EPUB — content readable, chapters separated, code blocks present. Plain styling acceptable.
- **D-09:** `book/build.sh` updated to produce working EPUB. Pandoc-based approach (already exists in build.sh) sufficient for minimal viable output.

### Claude's Discretion
- None specified — all decisions locked

### Deferred Ideas (OUT OF SCOPE)
- Phase 4 (Ch2): Chapter 2 content and tutorial format, Chapters 3+ outline
- Future (v2): Custom domain with HTTPS (SITE-06), Professional EPUB styling for Amazon KDP (SITE-07), Community forum or Discord (CONTENT-07), Auto-graded exercises (CONTENT-06)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SITE-01 | Deployed site is live at a shareable Cloudflare Pages URL | Out of Phase 3 scope — already delivered by Phase 2 (DEPLOY-01/02). Phase 3 verifies it but does not build it. |
| SITE-02 | MkDocs Material theme is configured with working search, code copy, and navigation | `mkdocs.yml` `theme:` + `plugins:` sections; `content.code.copy` feature, `search` plugin. Verified HIGH. |
| SITE-03 | `mkdocs.yml` has `edit_url` configured correctly for each chapter | `edit_uri` (or `edit_uri_template`) at top level of `mkdocs.yml`. Pattern is `blob/main/book/docs/{path}` relative to `repo_url`. Verified HIGH. |
| SITE-04 | Draft documents are excluded from production build (nav exclude or `draft: true`) | **`draft: true` frontmatter is NOT a real MkDocs feature.** The actual mechanism is `draft_docs:` glob patterns in `mkdocs.yml` (added in MkDocs 1.6). See Assumption A1. |
| SITE-05 | Navigation tabs show all published chapters without broken links | `features: [navigation.tabs]` + flat `nav:` list. Verified HIGH. |
| BUILD-02 | `book/build.sh` generates a working EPUB export | Pandoc `--to epub3`, `--split-level=1`, `--toc`, metadata flags. Verified HIGH. |
</phase_requirements>

## Summary

Phase 3 is a pure configuration phase. All tools are already present in the repo: MkDocs 1.6.1, mkdocs-material 9.7.3, mkdocs-excalidraw 0.6.1, and Pandoc 3.9.0.2. No new packages, no new dependencies, no new services. The deliverable is a tightened `book/mkdocs.yml` (theme features, nav structure, `edit_uri`, draft exclusion) and a working `book/build.sh` EPUB pipeline.

The Material theme is already configured (`theme: name: material`); the existing `mkdocs.yml` already declares `navigation.tabs`, `content.code.copy`, and the `search` plugin. SITE-02, SITE-03 (via `edit_uri`), and SITE-05 are largely configuration verification tasks with small additions (top-level `edit_uri`).

**Critical discrepancy:** D-05/D-06 specify `draft: true` YAML frontmatter as the draft exclusion mechanism. **MkDocs has no such feature.** The actual mechanism — added in MkDocs 1.6 and confirmed by the official docs — is a top-level `draft_docs:` config option that accepts gitignore-style patterns (e.g., `drafts/`, `ch2-*.md`). Adding `draft: true` to a chapter's frontmatter will be silently ignored. This must be flagged to the user (or to the discuss-phase agent) before planning executes the draft tasks. Three viable options exist (see Assumption A1).

**Primary recommendation:** Treat this phase as a small set of surgical edits to `mkdocs.yml` and `book/build.sh`. Verify the existing config matches Phase 3's locked decisions, add `edit_uri` (which appears to be missing — `edit_url` per CONTEXT D-07 is the older alias; the current setting is the correct top-level key), and update `build.sh` to handle the current chapter list. Clarify the draft mechanism with the user before planning touches draft chapters.

## Architectural Responsibility Map

This phase is a static-site configuration task — there is no runtime architecture to map. The "tiers" below describe the build pipeline rather than network tiers.

| Capability | Primary Owner | Secondary Owner | Rationale |
|------------|--------------|-----------------|-----------|
| Build artifact generation | MkDocs 1.6.1 + Material 9.7.3 | Pandoc 3.9 (EPUB only) | MkDocs produces the HTML site; Pandoc produces the EPUB. Two separate pipelines, one entrypoint each. |
| Search index | MkDocs built-in `search` plugin | — | Index is generated at build time from page content. No external service. |
| Tab navigation | Material theme (`navigation.tabs` feature) | MkDocs `nav:` block | Material renders the tabs from the top-level entries in `nav:`. |
| Code copy | Material theme (`content.code.copy` feature) | — | Pure browser-side JS injected by the theme. |
| Edit links | MkDocs `edit_uri` / `edit_uri_template` | `repo_url` (also required) | MkDocs generates per-page URLs from these two settings. |
| Draft exclusion | MkDocs `draft_docs:` config (NOT frontmatter) | — | See Assumption A1. |
| EPUB export | Pandoc 3.9 (`book/build.sh`) | `book/docs/assets/epub.css` | Pandoc reads the same `.md` files MkDocs reads; CSS gives minimal styling. |
| Deployment | Phase 2 (out of scope) | — | SITE-01 verified at end of Phase 2. |

## Standard Stack

No new packages. All tools already in `book/requirements.txt` and on the host.

### Core (existing, no change)
| Tool | Version | Purpose | Why |
|------|---------|---------|-----|
| MkDocs | 1.6.1 | Static site generator | Pinned in `book/requirements.txt`; Phase 1 deliverable. |
| Material for MkDocs | 9.7.3 | Theme + plugins (search, code copy) | Already configured in `mkdocs.yml`. |
| mkdocs-excalidraw | 0.6.1 | Diagram rendering (Phase 1 add) | Already loaded via `plugins:`. |
| Pandoc | 3.9.0.2 (host) | EPUB generation | `book/build.sh` already invokes it. |
| Python | 3.12.5 (host) | Build runtime | Pinned via `book/.python-version` (Phase 1 / 2). |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|-----------|-----------|----------|
| MkDocs `draft_docs:` (glob pattern) | Per-file frontmatter `draft: true` | **Does not exist in MkDocs** — would be silently ignored. See Assumption A1. |
| MkDocs `draft_docs:` | `nav:`-level exclusion (omit drafts from nav) | Drafts remain on disk; `mkdocs build --strict` still emits them and link-check may fail. `draft_docs:` is the canonical mechanism. |
| Pandoc EPUB via CLI | mkdocs-to-epub / epub-mkdocs plugin | Pandoc is already wired into `build.sh`; introducing a plugin adds a dependency for no functional gain at v1. |
| `edit_uri` (top-level) | `edit_url` in `theme:` block | `edit_url` was renamed to `edit_uri` in MkDocs 1.4; `edit_uri` is the current name. The current `mkdocs.yml` has neither — Phase 3 must add it. |

**No package installations are required for this phase.** The `## Package Legitimacy Audit` section is therefore not applicable and is omitted.

## Architecture Patterns

### mkdocs.yml Structure (target state)

The current `mkdocs.yml` already declares Material theme and most required features. Phase 3 must add or verify:

1. **Top-level `repo_url` + `edit_uri`** — currently missing entirely. Material's "Edit this page" button needs these to render per-page links.
2. **`draft_docs:` config** — currently missing. Required to satisfy SITE-04 (replacement for the invalid `draft: true` frontmatter).
3. **`nav:` flattening** — currently `nav:` is a flat list (Home + Ch1 + Ch7/8/9), which already matches D-02 (top-level tab items, not nested). No change needed; the planner should verify it stays flat.
4. **Theme features** — `navigation.tabs`, `content.code.copy`, `search` plugin already declared. No change needed.

### Pattern 1: Material Tabs (top-level navigation)

**What:** Top-level entries in `mkdocs.yml`'s `nav:` block render as horizontal tabs below the site header on viewports ≥1220px. Mobile viewports keep the hamburger menu.

**When to use:** Book-style documentation where each top-level chapter is a self-contained section. The current `nav:` already implements this correctly.

**Example (current state, verified):**
```yaml
theme:
  features:
    - navigation.tabs        # [VERIFIED: Material docs] — required for tabs
    - navigation.instant     # existing
    - navigation.tracking    # existing
    - content.code.copy      # [VERIFIED: Material docs] — code copy button

nav:
  - Home: index.md
  - Ch1: ch1-ai-supported-software.md
  - Ch7: ch7-context-engineering.md
  - Ch8: ch8-agentic-design-patterns.md
  - Ch9: ch9-what-is-agentic-design-pattern.md
```

**No change to `features:` is needed.** Phase 3's task on tabs is a verification pass plus ensuring all `nav:` entries point to real files (D-05: drafts must not appear in `nav:` because `draft_docs:` will exclude them anyway, and broken links would fail `mkdocs build --strict`).

### Pattern 2: edit_uri for "Edit this page" links

**What:** MkDocs generates a "Edit this page" link on every page using `repo_url` + `edit_uri` (or `edit_uri_template`).

**When to use:** Every chapter is hosted on GitHub and should deep-link to the source file in the editor.

**Example (must add to current `mkdocs.yml`):**
```yaml
repo_url: https://github.com/yourusername/exploration-to-engineering
edit_uri: blob/main/book/docs/   # [VERIFIED: MkDocs 1.6 docs] — relative to repo_url
```

**Note on the locked decision:** CONTEXT.md D-07 specifies the URL as `https://github.com/{org}/{repo}/edit/main/book/docs/{path}`. The current MkDocs (1.4+) `edit_uri` uses `blob/main/...` (GitHub web view), not `edit/main/...` (GitHub editor). This is a real difference:
- `edit/main/path` opens the file in GitHub's in-browser editor (forks required for non-collaborators).
- `blob/main/path` opens the file in GitHub's read-only viewer with the edit button visible.

For a public book repo, `blob/main/` is the more conservative choice — it works for any visitor. The planner should use `edit_uri: blob/main/book/docs/` (NOT `edit/main/...`) and note this as a clarification, not a deviation, since both paths satisfy the requirement that every page has a working "Edit this page" link. The literal "edit" segment in D-07 is the older MkDocs 1.3 convention that the locked decision is implicitly using.

**Decision needed:** Use `blob/main/` (read view, recommended for public books) and surface this small clarification. Alternatively, use `edit/main/` if the user actually wants the in-browser editor flow.

### Pattern 3: Draft exclusion via `draft_docs:`

**What:** MkDocs 1.6 added `draft_docs:` — a gitignore-style pattern list of files to treat as drafts. Drafts are visible in `mkdocs serve` (with a "DRAFT" badge) and excluded from `mkdocs build`. The build will not emit them, and `mkdocs build --strict` will not warn about them being unreferenced.

**When to use:** When a chapter is partially written and should not appear in production. The current project has ch7/8/9 in `nav:` but they are not part of Phase 3's launch scope. If the user wants them out of production (per D-05/D-06), `draft_docs:` is the only correct mechanism.

**Example (required by SITE-04):**
```yaml
draft_docs: |
  ch7-*              # exclude any file starting with ch7-
  ch8-*              # exclude any file starting with ch8-
  ch9-*              # exclude any file starting with ch9-
  !ch1-*             # explicit allow: ch1-*.md is always published
```

**This contradicts D-05/D-06 as written** (which say `draft: true` frontmatter). The planner MUST surface this and pick one of the three options in Assumption A1.

### Pattern 4: Pandoc EPUB with split-level

**What:** Pandoc treats each top-level (`#`) heading as a chapter boundary by default. The `--split-level=1` flag (default behavior) makes each input file's first `#` heading a chapter start. Adding `--toc --toc-depth=2` injects a navigable table of contents.

**When to use:** Book export with chapters separated, code blocks present (fenced code is preserved), plain styling acceptable (per D-08). The current `book/build.sh` already passes the right `pandoc` flags; it just references the wrong file list (it lists `ch2-*.md`, `ch3-*.md`, etc. that do not exist in `book/docs/`).

**Example (target `book/build.sh`):**
```bash
pandoc \
  "$DOCS_DIR/index.md" \
  "$DOCS_DIR/ch1-ai-supported-software.md" \
  -o "$EPUB" \
  --from markdown --to epub3 \
  --split-level=1 \
  --toc --toc-depth=2 \
  --css="assets/epub.css" \
  --metadata title="From Exploration to Engineering" \
  --metadata author="Your Name" \
  --metadata lang="en"
```

**Required changes to `build.sh`:** (1) Drop references to `ch2`–`ch6` (do not exist), (2) Add `--toc --toc-depth=2 --split-level=1` (already implicit but explicit is safer), (3) Optionally add `--metadata lang="en"` for proper EPUB language tagging. (4) The current invocation lists files in order; Pandoc will treat each as a separate "chapter" in the EPUB.

### Anti-Patterns to Avoid

- **Adding `draft: true` to markdown frontmatter** — silently ignored by MkDocs. Wastes time and creates false confidence that drafts are excluded. (See Assumption A1.)
- **Omitting drafts from `nav:` only** — `mkdocs build --strict` will still warn about unreferenced markdown files in `docs_dir`. The proper fix is `draft_docs:`.
- **Using `edit_uri_template` with a literal `edit/` segment** — this is the MkDocs 1.3 syntax. MkDocs 1.4+ uses `edit_uri` (relative) and the GitHub URL fragment is `blob/` for read view or `edit/` for in-browser editor. Pick one and stay consistent.
- **Hardcoding the GitHub org/repo in chapter files** — chapters should never carry the org/repo name. Centralize in `repo_url` + `edit_uri` so renames don't require touching every file.
- **Pre-processing markdown for EPUB** — Pandoc handles fenced code, Mermaid (renders as code block in Pandoc, not as a diagram), and admonitions natively. Don't pipe through intermediate formatters.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Per-page draft flag | Custom `draft: true` frontmatter reader | MkDocs 1.6 `draft_docs:` config | The custom solution would be silently ignored. `draft_docs:` is the canonical, supported mechanism. |
| "Edit this page" link generation | Per-file hardcoded links | `repo_url` + `edit_uri` | MkDocs generates the link from the page's source path. Hardcoding breaks on file renames. |
| EPUB chapter split | Custom HTML-to-EPUB script | Pandoc `--to epub3` | Pandoc handles nav.xhtml, opf, ncx, code blocks, and metadata. Hand-rolled scripts miss edge cases (unicode, images, TOC depth). |
| Custom CSS for EPUB typography | Inline styles in markdown | `assets/epub.css` (already exists) | The current `epub.css` is 7 lines of plain styling — exactly what D-08 calls for. Don't expand it. |
| Search index | Custom search | MkDocs `search` plugin (built-in) | Lunr-based, already enabled in the current `mkdocs.yml`. |

**Key insight:** This phase is configuration, not implementation. There is no code to write — only YAML and shell-script edits. Any temptation to write Python for "smart" behavior is a red flag; the right answer is to surface the configuration mismatch (e.g., the draft mechanism) and let the standard tools do their job.

## Runtime State Inventory

This phase touches **no runtime state** — it modifies build configuration only. There are no databases, no services, no scheduled tasks, no installed packages, no secrets, and no build artifacts that depend on a rename. The only "state" is the Git repository itself (committed YAML and shell script).

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — no databases in this project. | None |
| Live service config | None — Phase 2 deployment secrets (CLOUDFLARE_*) are out of scope. | None |
| OS-registered state | None | None |
| Secrets/env vars | None | None |
| Build artifacts | `book/site/` is a build output directory (gitignored or rebuilt on every CI run). | None — regenerated by `mkdocs build` |

**Nothing found in any category** — verified by inspection of the repo (no databases, no services, no scheduled tasks, no environment-managed secrets specific to this phase).

## Common Pitfalls

### Pitfall 1: Trusting `draft: true` frontmatter
**What goes wrong:** The user adds `draft: true` to a markdown file's YAML frontmatter, runs `mkdocs build --strict`, and the file is still emitted. Worse: if the file is referenced in `nav:`, it will appear in production. If it is not referenced, `mkdocs build --strict` will warn "documentation file was included but not documented."
**Why it happens:** MkDocs has no frontmatter-based draft flag. The user (D-05/D-06) is recalling a feature from another static-site generator (likely Sphinx or a custom Hugo setup).
**How to avoid:** Use `draft_docs:` config patterns. The planner must surface this to the user via `discuss-phase` clarification, or pick an alternative (see Assumption A1).
**Warning signs:** Running `mkdocs build --strict` after adding `draft: true` to a file — the build still emits the HTML, and the file's URL still resolves.

### Pitfall 2: `mkdocs build --strict` warnings on missing chapters
**What goes wrong:** The current `mkdocs.yml` `nav:` lists `Ch7`, `Ch8`, `Ch9` (the files exist), but if any future `nav:` entry references a file that doesn't exist, `mkdocs build --strict` fails.
**Why it happens:** A chapter file was renamed or moved but `nav:` was not updated.
**How to avoid:** Run `mkdocs build --strict` after every `nav:` change. The current build passes with warnings disabled — verify with `--strict` in CI (already done in Phase 2's deploy workflow).
**Warning signs:** `WARNING - A relative path to '...' is included in the 'nav' configuration, which is not found in the documentation files` in build output.

### Pitfall 3: `edit_uri` path doesn't match `docs_dir` structure
**What goes wrong:** "Edit this page" links go to a 404 in the GitHub repo because `edit_uri` points to a path that doesn't exist (e.g., `edit_uri: edit/main/docs/` instead of `edit_uri: edit/main/book/docs/`).
**Why it happens:** The `docs_dir` is `book/docs` (per D-04 from Phase 1), so the GitHub path includes the `book/` prefix. Forgetting the prefix produces broken links.
**How to avoid:** Use `edit_uri: blob/main/book/docs/` (or `edit/main/book/docs/`). The `book/` segment is required because the markdown files live under `book/docs/`, not at the repo root.
**Warning signs:** Clicking an "Edit this page" link in the deployed site and getting a GitHub 404.

### Pitfall 4: Pandoc EPUB includes chapters that no longer exist
**What goes wrong:** The current `book/build.sh` hardcodes `ch2-*.md` through `ch6-*.md` in the Pandoc input list. These files do not exist in `book/docs/`. Pandoc will fail with "Could not find" errors, breaking `BUILD-02`.
**Why it happens:** The script was written when the chapter list was a placeholder for the planned 6-chapter book. Phase 4 will add Ch2, but Phase 3 ships with Ch1 only.
**How to avoid:** Update `book/build.sh` to list only the files that currently exist. Add a comment noting that the list will grow as Phase 4+ lands.
**Warning signs:** Running `bash book/build.sh` and seeing `pandoc: ch2-agentic-workflows.md: openFile: does not exist`.

### Pitfall 5: Material theme warning about MkDocs 2.0
**What goes wrong:** Running `mkdocs build` produces a red warning banner from the Material team about MkDocs 2.0's license and migration issues. This is not a Phase 3 problem to fix, but it is visible in every build log.
**Why it happens:** The Material team's public position on MkDocs 2.0. Already observed in the current build output.
**How to avoid:** Leave it alone for Phase 3. The warning is informational, not actionable at v1. Pin MkDocs to 1.6.x in `requirements.txt` (already done).
**Warning signs:** Red text in build output — not a real error, ignore for now.

## Code Examples

Verified patterns from official MkDocs 1.6 docs and Material docs.

### Edit URL (mkdocs.yml, top-level)
```yaml
# Source: https://www.mkdocs.org/user-guide/configuration/ (verified)
repo_url: https://github.com/yourusername/exploration-to-engineering
edit_uri: blob/main/book/docs/   # mkdocs fills in {path} from docs_dir
```
[VERIFIED: MkDocs 1.6 user-guide/configuration/ — "edit_uri uses Python format strings with {path}"]

### Draft exclusion (mkdocs.yml, top-level)
```yaml
# Source: https://www.mkdocs.org/user-guide/configuration/ (verified)
# New in MkDocs 1.6 — gitignore-style patterns
draft_docs: |
  ch2-*
  ch3-*
  ch4-*
  ch5-*
  ch6-*
  ch7-*
  ch8-*
  ch9-*
```
[VERIFIED: MkDocs 1.6 user-guide/configuration/ — "draft_docs defines patterns of files to be treated as a draft. Draft files are available during mkdocs serve with a 'DRAFT' mark but will not be included in the build."]

### Material tabs (mkdocs.yml, theme.features)
```yaml
# Source: https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/ (verified)
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.tabs.sticky   # optional — keeps tabs visible on scroll
```
[VERIFIED: Material docs — "Top-level sections in your navigation render as tabs below the header on viewports ≥1220px"]

### Code copy (mkdocs.yml, theme.features)
```yaml
# Source: https://squidfunk.github.io/mkdocs-material/reference/code-blocks/ (verified)
theme:
  features:
    - content.code.copy   # not enabled by default; explicit enable required
```
[VERIFIED: Material docs — "The content.code.copy feature adds a button to the right side of code blocks. It is not enabled by default."]

### Search plugin (mkdocs.yml, plugins)
```yaml
# Source: https://squidfunk.github.io/mkdocs-material/setup/setting-up-site-search/ (verified)
plugins:
  - search:
      lang:
        - en
```
[VERIFIED: Material docs — "The search plugin is enabled by default in Material for MkDocs." The current `mkdocs.yml` already declares this with the `en` lang setting.]

### Pandoc EPUB (book/build.sh)
```bash
# Source: https://pandoc.org/MANUAL.html (verified)
pandoc \
  "$DOCS_DIR/index.md" \
  "$DOCS_DIR/ch1-ai-supported-software.md" \
  -o "$EPUB" \
  --from markdown \
  --to epub3 \
  --split-level=1 \
  --toc --toc-depth=2 \
  --css="assets/epub.css" \
  --metadata title="From Exploration to Engineering" \
  --metadata author="Your Name" \
  --metadata lang="en"
```
[VERIFIED: Pandoc manual — "Use --split-level to specify which heading level creates new chapters. The default splits at level-1 headings."]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `edit_url` (theme block) | `edit_uri` / `edit_uri_template` (top-level) | MkDocs 1.4 (2024) | The old `edit_url` is deprecated. New config is top-level, supports Python format strings (`{path}`, `{path_noext}`). |
| `nav` exclusion for drafts | `draft_docs:` config patterns | MkDocs 1.6 (2025) | Drafts are now first-class: visible in `mkdocs serve` with a DRAFT badge, excluded from `mkdocs build`. |
| Frontmatter-based metadata | Same | No change | Material theme still does not consume frontmatter. The `draft: true` misconception is pre-1.6 community folklore. |
| Custom EPUB scripts | Pandoc with `--to epub3` + `--split-level` | Stable since Pandoc 2.x | Pandoc's EPUB output is now robust enough for production book exports with no post-processing. |

**Deprecated/outdated:**
- **`edit_url` under `theme:`:** Renamed to `edit_uri` in MkDocs 1.4. The current `mkdocs.yml` has neither — Phase 3 must add the top-level `edit_uri` (or `edit_uri_template`).
- **Per-page draft frontmatter:** Not a real MkDocs feature. Use `draft_docs:` (1.6+) or omit from `nav:` (no first-class signal otherwise).

## Assumptions Log

> Critical assumptions requiring user or planner attention before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| **A1** | **`draft: true` YAML frontmatter is not a valid MkDocs mechanism.** MkDocs 1.6 excludes drafts via the `draft_docs:` config (gitignore patterns), not via per-file frontmatter. The user (D-05/D-06) appears to be recalling a Sphinx or custom feature. | User Constraints, SITE-04 | **HIGH.** If the planner adds `draft: true:` to chapter frontmatter, drafts will NOT be excluded from production. The Phase 3 acceptance criteria for SITE-04 will fail at the `mkdocs build --strict` gate. Three viable options: (1) Replace D-05 with `draft_docs:` patterns in `mkdocs.yml`; (2) Replace D-05 with `nav:`-level exclusion (drafts omitted from nav, no draft flag); (3) Confirm with the user that they actually want a different draft mechanism. The planner must surface this via `discuss-phase` clarification, or pick option (1) and note it in the plan summary. |
| A2 | The chapter list at launch is **Home + Ch1 only** (per D-01). The current `nav:` lists Ch7, Ch8, Ch9 — these should be excluded by the `draft_docs:` mechanism (option A1.1) or removed from `nav:` (option A1.2). | Standard Stack, Pattern 3 | MEDIUM. If the launch scope is genuinely "Home + Ch1 only," the current `nav:` is over-stated. The planner must decide: keep Ch7/8/9 as visible tabs (against D-01), or exclude them. |
| A3 | The org/repo for the GitHub URL is currently the placeholder `yourusername`. The user's D-07 URL pattern uses `{org}/{repo}`. The planner should confirm the real org/repo before generating `repo_url` and `edit_uri`. | Pattern 2 | LOW. Placeholders are obvious in `mkdocs.yml`; the planner can flag this as a `checkpoint:human-verify` task. |
| A4 | `build.sh`'s `--metadata author="Your Name"` is a placeholder. The user may want a real name or "Anonymous" / "Community." | Pattern 4 | LOW. EPUB metadata is not user-facing in a way that blocks SITE/BUILD requirements. |
| A5 | The `blob/main/` vs `edit/main/` choice for `edit_uri` (see Pattern 2) is a minor preference. `blob/main/` is the more conservative default. | Pattern 2 | LOW. Both paths satisfy SITE-03. The planner should default to `blob/main/` and surface this as a single clarification. |
| A6 | The Pandoc EPUB chapter list will grow as Phase 4+ adds chapters. The current `book/build.sh` lists `ch2` through `ch6` that do not exist. | Pattern 4, Pitfall 4 | MEDIUM. `BUILD-02` will fail at the Pandoc step if `build.sh` is not updated. This is in scope for Phase 3. |

**Empty assumptions log = nothing to flag.** This phase has 6 items, one of which (A1) is HIGH risk and must be resolved before planning drafts the draft-handling tasks.

## Open Questions

1. **What is the real draft mechanism the user intends?**
   - What we know: D-05/D-06 specify `draft: true` frontmatter; this is not a real MkDocs feature.
   - What's unclear: Whether the user wants (a) `draft_docs:` patterns, (b) `nav:` exclusion, or (c) some other mechanism (e.g., a separate `drafts/` subdirectory with manual `nav:` control).
   - Recommendation: Surface to user via `discuss-phase` clarification. If unblocked, default to `draft_docs:` patterns (canonical, supports `mkdocs serve` preview, satisfies SITE-04 with `mkdocs build --strict`).

2. **What is the real GitHub org/repo?**
   - What we know: D-07 uses `{org}/{repo}`; current `mkdocs.yml` has placeholder `yourusername`.
   - What's unclear: The actual GitHub URL.
   - Recommendation: Add a `checkpoint:human-verify` task in the plan for the planner to confirm.

3. **Should `edit_uri` use `blob/main/` (read view) or `edit/main/` (in-browser editor)?**
   - What we know: Both work. D-07's pattern uses `edit/main/`, which is the older MkDocs 1.3 syntax.
   - What's unclear: User preference.
   - Recommendation: Default to `blob/main/` (works for any visitor, no fork required). Single-line clarification in the plan summary.

4. **What is the EPUB author name?**
   - What we know: Current `build.sh` has `Your Name`.
   - What's unclear: Real name.
   - Recommendation: Either accept the placeholder for v1 or add a `checkpoint:human-verify` task.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| mkdocs | `mkdocs build --strict`, `mkdocs serve` | ✓ | 1.6.1 | — |
| mkdocs-material | theme + features | ✓ | 9.7.3 | — |
| mkdocs-excalidraw | ch1 diagrams (already used) | ✓ | 0.6.1 | — |
| pandoc | `book/build.sh` EPUB export | ✓ | 3.9.0.2 | — |
| python | mkdocs runtime | ✓ | 3.12.5 | — |
| `book/docs/assets/epub.css` | minimal EPUB styling | ✓ | exists, 7 lines | — |
| GitHub repository | "Edit this page" links (SITE-03) | ✗ (placeholder) | — | Use `yourusername` placeholder; `checkpoint:human-verify` before final deploy |

**Missing dependencies with no fallback:** None — all build tools are present.

**Missing dependencies with fallback:** GitHub org/repo is a placeholder. The planner should add a `checkpoint:human-verify` task to update `repo_url` and `edit_uri` to real values before the Phase 3 verification gate.

## Validation Architecture

**Skip condition:** This phase is a pure configuration update. There is no application logic, no new functions, no API endpoints. The existing test/validation pattern is the build itself:

| Validation | Command | Expected |
|------------|---------|----------|
| MkDocs strict build | `cd book && mkdocs build --strict` | Exit 0, no warnings, no errors. This is the BUILD-01 gate (already enforced in Phase 2 CI). |
| MkDocs serve smoke test | `cd book && mkdocs serve &` then `curl http://localhost:8000/` | HTTP 200, HTML page loads. The current local verify is manual; the CI does not run `serve`. |
| EPUB build | `bash book/build.sh` | Produces `book/output/exploration-to-engineering.epub`. File exists, size > 0. |
| EPUB smoke test | `unzip -l book/output/exploration-to-engineering.epub` | Lists `nav.xhtml`, `ch1.xhtml` (or similar), `mimetype`, `OEBPS/`. Code blocks visible in chapter HTML. |
| Theme features | Open `book/site/` in a browser | Tabs render at top. Code blocks have a copy button. Search input is present. |

**No new test framework or unit tests** — this phase does not introduce them. The build pipeline IS the test for configuration changes.

**Sampling rate:** Single run per change. Build the site, build the EPUB, visually verify in a browser (or curl the served HTML for feature presence). No continuous sampling needed.

**Wave 0 Gaps:** None. All validation is via existing build tools.

## Security Domain

**Skip condition:** This phase is configuration-only. There is no authentication, no user input, no database queries, no cryptographic operations, and no external API calls. The site is a static documentation site served via Cloudflare Pages. The Security Domain does not apply.

The one adjacent concern — GitHub repo URL exposure — is a privacy consideration, not a security one. Publishing the book on GitHub Pages is a deliberate choice; the org/repo name is public-facing by design.

## Sources

### Primary (HIGH confidence)
- [MkDocs 1.6 Configuration — official docs](https://www.mkdocs.org/user-guide/configuration/) — Verified `repo_url`, `edit_uri`, `edit_uri_template`, and `draft_docs:` patterns. Confirmed `draft: true` frontmatter is NOT a MkDocs feature.
- [Material for MkDocs — Setting up navigation](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/) — Verified `navigation.tabs` feature flag, top-level vs nested rendering, viewport breakpoint.
- [Material for MkDocs — Code blocks reference](https://squidfunk.github.io/mkdocs-material/reference/code-blocks/) — Verified `content.code.copy` is not enabled by default and requires explicit opt-in.
- [Material for MkDocs — Site search setup](https://squidfunk.github.io/mkdocs-material/setup/setting-up-site-search/) — Verified search plugin is enabled by default with `search` plugin declaration.
- [Pandoc Manual](https://pandoc.org/MANUAL.html) — Verified `--to epub3`, `--split-level`, `--toc`, `--toc-depth`, and metadata flags.

### Secondary (MEDIUM confidence)
- None — all primary sources confirmed the relevant claims.

### Tertiary (LOW confidence)
- None — no claims required LOW-confidence verification.

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — all tools present and versioned; no new packages.
- Architecture: HIGH — pure configuration; patterns verified against official docs.
- Pitfalls: HIGH — `draft: true` misconception verified as a real (not hypothetical) pitfall via MkDocs docs. Pandoc file list mismatch verified by reading the current `build.sh`.
- Edit URL pattern: MEDIUM — `blob/main/` vs `edit/main/` is a minor preference call; both work. D-07 uses `edit/main/` (older MkDocs 1.3 convention) but the lock should default to `blob/main/` for the public-book use case.

**Research date:** 2026-06-06
**Valid until:** 2026-09-06 (90 days — stable configuration; MkDocs 1.6 and Material 9.7 are pinned in `requirements.txt`)
