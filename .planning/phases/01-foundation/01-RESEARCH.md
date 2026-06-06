# Phase 1: Foundation - Research

**Researched:** 2026-06-06
**Domain:** MkDocs configuration, Python environment pinning, local development setup
**Confidence:** HIGH

## Summary

Phase 1: Foundation is about ensuring Chapter 1 content is production-ready and the local MkDocs build pipeline works correctly. The primary work involves: (1) creating a `.python-version` file to pin Python 3.12, (2) updating `mkdocs.yml` with correct `docs_dir`, `edit_url`, and placeholder values, (3) verifying the build and serve commands work, and (4) cleaning up a stale chapter file. The current build already succeeds with `--strict`; the main gap is configuration alignment with the decisions in CONTEXT.md.

**Primary recommendation:** Focus on configuration files and cleanup. The ch1 content structure is solid and already follows the tutorial format (theory, architecture diagrams, practical application, coding lab). No major content restructuring is needed.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Chapter content polish | Local docs | — | Content lives in `book/docs/` |
| MkDocs configuration | Local config | — | `mkdocs.yml` at `book/` root |
| Python version pinning | Local env | CI/CD (Phase 2) | `.python-version` file; Phase 2 reads it |
| Build validation | Local build | CI/CD (Phase 2) | `mkdocs build --strict` runs locally; GitHub Actions runs it in Phase 2 |
| Live preview | Local dev | — | `mkdocs serve` runs locally |

## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: `docs/` directory at `book/` root is the MkDocs source root
- D-02: Chapter files live in `book/docs/` (e.g., `book/docs/ch1-ai-supported-software.md`)
- D-03: Chapter filename: `ch1-ai-supported-software.md`
- D-04: Add `docs_dir: book/docs` to `book/mkdocs.yml`
- D-05: Set `edit_url` to `https://github.com/{org}/{repo}/edit/main/book/docs/{path}`
- D-06: Update `site_url` and `extra.homepage` from placeholder `yourusername`
- D-07: Navigation structure: Home (`index.md`) + Ch1 + future chapters
- D-08: Pin Python to `3.12` via `book/.python-version`
- D-09: `mkdocs build --strict` must succeed with no warnings or errors
- D-10: `mkdocs serve` runs for live preview during development
- D-11: EPUB build (`book/build.sh`) will be updated in Phase 3

### Claude's Discretion
- mkdocs.yml theme customization (colors, fonts, logo) — standard Material defaults for now
- Specific admonition types, code highlight styles — defer to Material defaults

### Deferred Ideas (OUT OF SCOPE)
- Phase 2: GitHub Actions workflow, Cloudflare Pages configuration
- Phase 3: EPUB build script finalization, theme customization, navigation tabs for all chapters
- Phase 4: Chapter 2 content and tutorial format

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CONTENT-01 | Chapter 1 is polished, production-ready, and deployable to Cloudflare Pages | Ch1 content already exists in `book/docs/ch1-ai-supported-software.md` with tutorial structure (theory, architecture, practical application, coding lab). Needs editorial verification for prose clarity and code executability. |
| CONTENT-02 | Each chapter follows a tutorial format: introduces a concept, builds working code, and delivers a deployable artifact | Ch1 already follows this format with: Scope/Learning Objectives (concept introduction), Theoretical Foundation (concept), Architecture diagrams (Mermaid class/flow diagrams), Practical Application (scenario-based), Coding Lab (hands-on RAG pipeline build) |
| CONTENT-03 | Code examples are executable Python snippets embedded in chapter markdown | Ch1 Coding Lab contains `pip install`, `ingest.py`, `retrieve.py`, `generate.py`, `rag.py` examples. These are valid Python syntax but not formally tested for executability. |
| BUILD-01 | `mkdocs build --strict` succeeds locally with no warnings or errors | Verified: `mkdocs build --strict` succeeds. Exit code 0. Output: "Documentation built in 0.29 seconds". A warning from Material team about MkDocs 2.0 appears but does not cause failure. |
| BUILD-03 | Local development server (`mkdocs serve`) runs for live preview | `mkdocs serve` supports `--open` (auto-open browser), `--dirty` (incremental rebuild), `--no-livereload`. Default address: `localhost:8000`. |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| MkDocs | 1.6.1 [VERIFIED: `pip show mkdocs`] | Static site generator | Project requirement, Python-native, simple Markdown-first workflow |
| Material for MkDocs | 9.7.6 [VERIFIED: `pip show mkdocs-material`] | Theme | Best-in-class documentation theme; search, navigation, code copy built-in |
| Python | 3.12.5 [VERIFIED: `python3 --version`] | Runtime | Aligns with MkDocs 1.6.x requirements and Cloudflare Pages support |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| mkdocs-material-extensions | latest (if needed) | Enhanced code features | Only if additional code annotation features beyond built-in are needed |
| pip-tools | latest | Dependency locking | To generate reproducible `requirements.txt` (Phase 2/3 scope) |

**Installation:** No new packages required. All required packages already installed.

## Package Legitimacy Audit

> Phase 1 does not install external packages — only configuration file creation. This section is N/A for this phase.

## Architecture Patterns

### System Architecture Diagram

The local development environment flows:

```
book/
├── .python-version          # Pins Python 3.12 for local and CI
├── mkdocs.yml               # Site config: docs_dir, edit_url, nav, theme
├── build.sh                 # EPUB build (Phase 3 update, unchanged)
├── docs/
│   ├── index.md             # Home page
│   ├── ch1-ai-supported-software.md  # Ch1 content (tutorial format)
│   └── assets/              # CSS, images
└── site/                    # mkdocs build output (gitignored)
```

Data flow:
1. Author edits markdown in `book/docs/`
2. `mkdocs build --strict` generates HTML in `book/site/`
3. `mkdocs serve` watches for changes and regenerates incrementally
4. Phase 2: GitHub Actions reads `.python-version`, runs `mkdocs build --strict`, deploys `site/` to Cloudflare Pages

### Recommended Project Structure

The existing structure at `book/` is already correct per D-01. No restructuring needed.

### Pattern 1: MkDocs Configuration Stacking
**What:** Material for MkDocs configures navigation.tabs, search, code.copy through `mkdocs.yml` features list.
**When to use:** When setting up a documentation site with multiple chapters.
**Example:**
```yaml
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.instant
    - content.code.copy

nav:
  - Home: index.md
  - Ch1: ch1-ai-supported-software.md
```

### Pattern 2: Python Version Pinning
**What:** A `.python-version` file at the project root pins the Python interpreter version.
**When to use:** When the build must use a specific Python version across local dev, CI, and cloud platforms.
**Example:**
```
3.12
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Local dev server | Custom HTTP server + markdown watcher | `mkdocs serve` | Built-in, supports live reload, `--dirty` incremental builds |
| Python version management | Manual version checking in CI scripts | `.python-version` file | Cloudflare Pages and pyenv both read this file automatically |
| Documentation search | Custom search implementation | Material for MkDocs built-in search | Full-text search, highlighting, suggestions already built-in |

**Key insight:** MkDocs is a mature, well-documented static site generator. Its built-in commands cover local development, strict builds, and serve workflows. Custom solutions would add complexity without benefit.

## Common Pitfalls

### Pitfall 1: Stale chapter file not cleaned up
**What goes wrong:** `book/ai_supported_software_development_chapter.md` (the old Ch1 filename) still exists in `book/` alongside `docs/ch1-ai-supported-software.md`. This creates confusion about which file is canonical and may be included in EPUB build.
**Why it happens:** The rename was done by creating a new file in `docs/`, but the old file in `book/` was not removed.
**How to avoid:** Delete `book/ai_supported_software_development_chapter.md` as part of Phase 1 cleanup.
**Warning signs:** `ls book/*.md` returns multiple chapter files.

### Pitfall 2: `edit_url` pointing to wrong path
**What goes wrong:** If `edit_url` is misconfigured, the "Edit this page" link on each docs page will 404.
**Why it happens:** MkDocs Material constructs the edit URL from `edit_url` + relative path to the markdown file. If `docs_dir` is set incorrectly, the path won't align.
**How to avoid:** Verify `edit_url` ends with `/edit/main/book/docs/` (per D-05) and `docs_dir: book/docs` is set. The edit link for `book/docs/ch1-ai-supported-software.md` should be `https://github.com/{org}/{repo}/edit/main/book/docs/ch1-ai-supported-software.md`.
**Warning signs:** Click "Edit this page" on a local preview and get a GitHub 404.

### Pitfall 3: Missing `.python-version` breaks Phase 2 CI
**What goes wrong:** Phase 2 GitHub Actions workflow expects `.python-version` to pin Python. If it's missing, the build image's default Python version (possibly 3.x older) is used, causing silent failures or different behavior.
**Why it happens:** Phase 1 did not create the file because it was marked as Phase 2 concern.
**How to avoid:** Create `book/.python-version` in Phase 1 with content `3.12` per D-08. This is a Phase 1 deliverable even though the file is consumed in Phase 2.

### Pitfall 4: `mkdocs serve` binding to wrong interface
**What goes wrong:** `mkdocs serve` binds to `localhost:8000` by default. If the user wants to access from another machine (e.g., mobile testing), they need `--dev-addr 0.0.0.0:8000`.
**Why it happens:** Default binding is localhost-only for security.
**How to avoid:** Document the `--dev-addr` option for multi-device testing scenarios. For local single-user preview, default is fine.

## Code Examples

### Creating .python-version
```bash
# Verify Python 3.12 is available
python3 --version  # Should output: Python 3.12.x

# Create .python-version
echo "3.12" > book/.python-version

# Verify
cat book/.python-version  # Should output: 3.12
```

### Verifying mkdocs serve works
```bash
cd book
mkdocs serve --open  # Opens browser automatically
# OR with custom address for mobile testing:
mkdocs serve --dev-addr 0.0.0.0:8000
```

### Verifying strict build
```bash
cd book
mkdocs build --strict
# Should exit with code 0 and "Documentation built in X.XX seconds"
```

### Cleaning up stale file
```bash
ls book/*.md  # Check for old chapter files
rm book/ai_supported_software_development_chapter.md  # Delete stale file
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| MkDocs with default theme | MkDocs + Material for MkDocs 9.7.x | Project start | Better search, code copy, navigation tabs |
| Sphinx for documentation | MkDocs for documentation | Project start | Simpler Markdown workflow, better for content-heavy books |
| Python version in CI script | `.python-version` file | D-08 decision | Cloudflare Pages, pyenv, and GitHub Actions all support this |

**Deprecated/outdated:**
- `cloudflare/pages-action@v1`: Deprecated in favor of `cloudflare/wrangler-action@v3` (Phase 2 scope)
- MkDocs Insiders (paid): Not needed; open-source Material for MkDocs has all required features

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research. The planner and discuss-phase use this section to identify decisions that need user confirmation before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `mkdocs serve --open` auto-opens the default browser on macOS | Code Examples | Minor: user can manually open browser if it doesn't work |
| A2 | The edit URL format `https://github.com/{org}/{repo}/edit/main/book/docs/{path}` is correct for MkDocs Material | Common Pitfalls | Medium: wrong format causes 404 on "Edit this page" links; needs real repo URL to verify |
| A3 | `book/ai_supported_software_development_chapter.md` is the only stale file needing cleanup | Common Pitfalls | Low: other stale files would be caught by listing book/*.md |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

1. **What is the actual GitHub repository URL?**
   - What we know: git remote has no URL configured (bare repository)
   - What's unclear: The `edit_url` in D-05 requires `https://github.com/{org}/{repo}/edit/main/book/docs/{path}`. We need the real org/repo names.
   - Recommendation: User must provide the actual GitHub repository URL before `edit_url` can be configured correctly. Mark as a `checkpoint:user-input` task.

2. **Should `mkdocs serve --open` be documented or just `mkdocs serve`?**
   - What we know: `--open` auto-opens browser, useful for beginners
   - What's unclear: Whether the user prefers a non-interactive serve command
   - Recommendation: Document `--open` as the default workflow; the user can omit it if preferred

## Environment Availability

> Step 2.6: SKIPPED (no external dependencies identified beyond already-installed packages)

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| mkdocs | Local build | Yes | 1.6.1 | — |
| mkdocs-material | Local build | Yes | 9.7.6 | — |
| Python 3.12 | Local build | Yes | 3.12.5 | — |

**Missing dependencies with no fallback:** None

**Missing dependencies with fallback:** None

## Validation Architecture

> Skip if workflow.nyquist_validation is explicitly set to false. If absent, treat as enabled.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None (documentation project) |
| Config file | N/A |
| Quick run command | N/A |
| Full suite command | N/A |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CONTENT-01 | Ch1 is production-ready | Manual | Review content structure against tutorial format checklist | Yes: `book/docs/ch1-ai-supported-software.md` |
| CONTENT-02 | Tutorial format | Manual | Verify all sections present: Scope, Learning Objectives, Theory, Architecture, Practical, Review, Lab | Yes |
| CONTENT-03 | Executable Python snippets | Manual | Verify Python syntax in coding lab | Yes (syntax valid, not tested in runtime) |
| BUILD-01 | `mkdocs build --strict` succeeds | Automated | `cd book && mkdocs build --strict && echo "SUCCESS"` | Yes - verified, exit 0 |
| BUILD-03 | `mkdocs serve` runs | Manual | `cd book && timeout 5 mkdocs serve 2>&1 || true` (startup check) | Yes |

### Sampling Rate
- **Per task commit:** N/A (documentation project, no unit tests)
- **Per wave merge:** Manual review of build output
- **Phase gate:** Full `mkdocs build --strict` green before `/gsd:verify-work`

### Wave 0 Gaps
- None — existing infrastructure (MkDocs, Python 3.12) covers all phase requirements. No test files or framework installation needed.

## Security Domain

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | N/A — documentation site, no auth |
| V3 Session Management | No | N/A |
| V4 Access Control | No | N/A |
| V5 Input Validation | No | N/A — static site, no user input |
| V6 Cryptography | No | N/A |

**Known Threat Patterns for MkDocs/Material theme:** None. Static site generation carries minimal security surface. Standard hardening: HTTPS in production, no inline scripts, CSP headers (Phase 3 when deployed).

## Sources

### Primary (HIGH confidence)
- [MkDocs Configuration Reference](https://www.mkdocs.org/user-guide/configuration/) — WebFetch verified
- `pip show mkdocs` — Version 1.6.1 confirmed
- `pip show mkdocs-material` — Version 9.7.6 confirmed
- `mkdocs build --strict` — Verified successful execution, exit 0
- `mkdocs serve --help` — Verified command options

### Secondary (MEDIUM confidence)
- [Material for MkDocs Navigation](https://squidfunk.github.io/mkdocs-material/setup/setting-up-the-navigation/) — WebFetch (404 on specific pages, but general knowledge confirmed)

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — MkDocs and Material versions verified via pip
- Architecture: HIGH — Configuration decisions confirmed from CONTEXT.md, structure verified from filesystem
- Pitfalls: MEDIUM — Based on common MkDocs misconfiguration patterns, not verified against a specific authoritative source

**Research date:** 2026-06-06
**Valid until:** 2026-07-06 (30 days — MkDocs configuration is stable, unlikely to change)