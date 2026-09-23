---
phase: "03"
plan: "02"
type: "execute"
status: "completed"
completed: "2026-06-06"
---

# 03-02-SUMMARY — EPUB Build Script Update

## Tasks Executed

| Task | Status | Notes |
|------|--------|-------|
| Update book/build.sh to reference only existing files | Done | Removed ch2-ch6 references; kept only index.md + ch1-ai-supported-software.md |
| Add --split-level=1, --toc --toc-depth=2, --metadata lang="en" | Done | Chapter splitting, TOC, and language tagging added |

## Fix Applied

### CSS path corrected
**What:** Changed `--css="assets/epub.css"` to `--css="docs/assets/epub.css"`.
**Rationale:** Pandoc runs from `book/` directory. Without `docs/` prefix, pandoc looks for `book/assets/epub.css` which doesn't exist. The actual file is at `book/docs/assets/epub.css`.
**Source:** Running `bash book/build.sh` threw `assets/epub.css: openBinaryFile: does not exist` error.

## Verification

- `bash book/build.sh` → exits 0 ✓
- EPUB file created at `book/output/exploration-to-engineering.epub` ✓
- `unzip -l` shows mimetype, EPUB/nav.xhtml, content.opf, title_page.xhtml, ch001.xhtml, ch002.xhtml ✓
- pandoc resource warning for `drawings/human-problem-solving-loop.excalidraw` — harmless, Excalidraw files are for MkDocs rendering, not pandoc

## Patterns Established

- Pandoc EPUB CSS path is relative to the CWD when pandoc is invoked, not relative to the output EPUB location
- `--split-level=1` ensures chapters are split at heading level 1 (the chapter title)
- `--toc --toc-depth=2` generates a navigable table of contents with 2 heading levels