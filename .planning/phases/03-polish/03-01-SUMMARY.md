---
phase: "03"
plan: "01"
type: "execute"
status: "completed"
completed: "2026-06-06"
---

# 03-01-SUMMARY — mkdocs.yml Configuration

## Tasks Executed

| Task | Status | Notes |
|------|--------|-------|
| Add repo_url and edit_uri | Done | `repo_url`, `edit_uri: blob/main/book/docs/` added after site_url |
| Update nav structure (Home + Ch1 only) | Done | Removed ch7/8/9 from nav |
| Add draft_docs for ch7/8/9 | Done | `draft_docs: \| ch7-* ch8-* ch9-*` — ch7/8/9 absent from site/ build |
| Human checkpoint (GitHub org/repo) | PENDING | Task 4 blocked — user must confirm real org/repo |

## Auto-Fix Applied During Execution

### CSS path fix (applied to 03-02 build.sh, documented here)
**What:** Changed `--css="assets/epub.css"` to `--css="docs/assets/epub.css"` in book/build.sh.
**Rationale:** Pandoc runs from `book/` directory, so CSS path must be relative to that. `assets/epub.css` doesn't exist at book level — only at `book/docs/assets/epub.css`.
**Source:** Discovered when running `bash book/build.sh` during 03-02 execution.

## Issues Encountered

### Edit links not rendering (SITE-03 gap)
**What:** Despite correct `repo_url`, `edit_uri`, and `navigation.edit.page` feature flag, the generated HTML contains no `edit-this-page` links.
**Context:** Material for MkDocs 9.7.6 does not render the edit link despite all config being correct. The `repo_url` renders correctly in the header source link, confirming connectivity. The edit link simply does not appear in the footer.
**Impact:** SITE-03 ("every page has Edit this page link") is not fully satisfied.
**Resolution:** Human checkpoint (Task 4) must verify the actual GitHub org/repo. If edit links still don't appear after the real org/repo is set, the `edit_uri` path may need to be `blob/main/docs/` (if docs are at repo root) or a different configuration.

## Verification

- `cd book && mkdocs build --strict` → exits 0 ✓
- ch7/8/9 absent from `site/` directory ✓ (draft_docs working)
- `repo_url` renders in header source link ✓
- `navigation.edit.page` feature built successfully ✓
- `nav` shows only Home + Ch1 ✓

## Patterns Established

- `draft_docs:` in mkdocs.yml is the correct MkDocs 1.6 mechanism for excluding draft content from production builds
- `navigation.edit.page` is the Material for MkDocs feature flag for edit links
- `edit_uri: blob/main/book/docs/` is the correct path format for MkDocs 1.4+

## Deviations From Plan

1. **navigation.edit.page feature added** — not in original plan tasks, added to actually enable edit links as SITE-03 requires
2. **CSS path fix** — applied to 03-02's build.sh during 03-01 execution, documented here for cross-reference