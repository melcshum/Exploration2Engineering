# Phase 3: Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-06
**Phase:** 03-Polish
**Areas discussed:** Navigation structure, draft exclusion, edit_url confirm, EPUB styling, code copy button

---

## Navigation Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Top-level tabs | Home + Ch1 as tabs at the top — clean, book-like, scales to multiple chapters | ✓ |
| Sections with children | Section headers with chapters as nested items | |
| Flat list | All chapters at same level, no hierarchy | |

**User's choice:** Top-level tabs (Recommended)
**Notes:** Clean, book-like. Extensible to more chapters as they are added.

---

## Draft Exclusion

| Option | Description | Selected |
|--------|-------------|----------|
| draft: true frontmatter | Add draft: true to each draft chapter's frontmatter — MkDocs excludes automatically | ✓ |
| exclude_docs pattern in mkdocs.yml | Code-level exclusion in mkdocs.yml | |
| Separate drafts/ directory | Move drafts outside docs/ — filesystem-level exclusion | |

**User's choice:** draft: true frontmatter (Recommended)
**Notes:** Simple, markdown-native, doesn't require extra config.

---

## edit_url Pattern

| Option | Description | Selected |
|--------|-------------|----------|
| Confirm: github.com/{org}/{repo}/edit/main/book/docs/{path} | Keep the pattern from Phase 1 | ✓ |
| Adjust the pattern | Change the edit_url pattern | |

**User's choice:** Confirm: github.com/{org}/{repo}/edit/main/book/docs/{path}
**Notes:** Pattern confirmed from Phase 1.

---

## EPUB Styling

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal viable | Content readable, chapters separated, code blocks present — plain styling OK | ✓ |
| Properly styled | Professional typography, styled code blocks, proper ebook formatting | |

**User's choice:** Minimal viable (Recommended)
**Notes:** Plain styling acceptable. Pandoc-based build.sh sufficient for this bar.

---

## Code Copy Button

| Option | Description | Selected |
|--------|-------------|----------|
| Enable code copy button | Built-in Material feature — one click to copy code block contents | ✓ |
| Disable | No code copy button | |

**User's choice:** Enable code copy button (Recommended)
**Notes:** Built-in Material feature, no extra config needed.

---

## Deferred Ideas

### Phase 4 (Ch2)
- Chapter 2 content and tutorial format
- Chapters 3+ outline

### Future (v2)
- Custom domain with HTTPS (SITE-06)
- Professional EPUB styling for Amazon KDP (SITE-07)
- Community forum or Discord (CONTENT-07)
- Auto-graded exercises (CONTENT-06)