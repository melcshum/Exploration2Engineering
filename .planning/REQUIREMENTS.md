# Requirements — From Exploration to Engineering

## Traceability

| REQ-ID | Requirement | Phase | Status |
|--------|-------------|-------|--------|
| CONTENT-01 | Chapter 1 is polished, production-ready, and deployable to Cloudflare Pages | Phase 1 | active |
| CONTENT-02 | Each chapter follows a tutorial format: introduces a concept, builds working code, and delivers a deployable artifact | Phase 1 | active |
| CONTENT-03 | Code examples are executable Python snippets embedded in chapter markdown | Phase 1 | active |
| BUILD-01 | `mkdocs build --strict` succeeds locally with no warnings or errors | Phase 1 | active |
| BUILD-03 | Local development server (`mkdocs serve`) runs for live preview | Phase 1 | active |
| DEPLOY-01 | GitHub Actions workflow (`.github/workflows/deploy.yml`) builds the MkDocs site on every push to main | Phase 2 | active |
| DEPLOY-02 | Workflow uses `cloudflare/wrangler-action@v3` to deploy to Cloudflare Pages | Phase 2 | active |
| DEPLOY-03 | `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured as GitHub repository secrets | Phase 2 | active |
| DEPLOY-04 | Build command is `mkdocs build --strict` with output directory `site/` | Phase 2 | active |
| DEPLOY-05 | Python version is pinned via `.python-version` to prevent silent breakage from build image upgrades | Phase 2 | active |
| SITE-01 | Deployed site is live at a shareable Cloudflare Pages URL | Phase 3 | active |
| SITE-02 | MkDocs Material theme is configured with working search, code copy, and navigation | Phase 3 | active |
| SITE-03 | `mkdocs.yml` has `edit_url` configured correctly for each chapter | Phase 3 | active |
| SITE-04 | Draft documents are excluded from production build (nav exclude or `draft: true`) | Phase 3 | active |
| SITE-05 | Navigation tabs show all published chapters without broken links | Phase 3 | active |
| BUILD-02 | `book/build.sh` generates a working EPUB export | Phase 3 | active |
| CONTENT-04 | Chapter 2 is drafted, covers LLM integration patterns, and builds a deployable project | Phase 4 | active |
| CONTENT-05 | Chapters 3+ are outlined with sufficient depth for a multi-chapter curriculum | Phase 4 | active |

---

## v1 Requirements

### CONTENT — Chapter Content

- [ ] **CONTENT-01**: Chapter 1 is polished, production-ready, and deployable to Cloudflare Pages
- [ ] **CONTENT-02**: Each chapter follows a tutorial format: introduces a concept, builds working code, and delivers a deployable artifact
- [ ] **CONTENT-03**: Code examples are executable Python snippets embedded in chapter markdown
- [ ] **CONTENT-04**: Chapter 2 is drafted, covers LLM integration patterns, and builds a deployable project
- [ ] **CONTENT-05**: Chapters 3+ are outlined with sufficient depth for a multi-chapter curriculum

### DEPLOY — CI/CD Pipeline

- [ ] **DEPLOY-01**: GitHub Actions workflow (`.github/workflows/deploy.yml`) builds the MkDocs site on every push to main
- [ ] **DEPLOY-02**: Workflow uses `cloudflare/wrangler-action@v3` to deploy to Cloudflare Pages
- [ ] **DEPLOY-03**: `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured as GitHub repository secrets
- [ ] **DEPLOY-04**: Build command is `mkdocs build --strict` with output directory `site/`
- [ ] **DEPLOY-05**: Python version is pinned via `.python-version` to prevent silent breakage from build image upgrades

### SITE — Book Site

- [ ] **SITE-01**: Deployed site is live at a shareable Cloudflare Pages URL
- [ ] **SITE-02**: MkDocs Material theme is configured with working search, code copy, and navigation
- [ ] **SITE-03**: `mkdocs.yml` has `edit_url` configured correctly for each chapter
- [ ] **SITE-04**: Draft documents are excluded from production build (nav exclude or `draft: true`)
- [ ] **SITE-05**: Navigation tabs show all published chapters without broken links

### BUILD — Local Development

- [ ] **BUILD-01**: `mkdocs build --strict` succeeds locally with no warnings or errors
- [ ] **BUILD-02**: `book/build.sh` generates a working EPUB export
- [ ] **BUILD-03**: Local development server (`mkdocs serve`) runs for live preview

---

## v2 Requirements (Deferred)

- [ ] **CONTENT-06**: Chapters include exercises with solution hints (auto-graded deferred)
- [ ] **CONTENT-07**: Community forum or Discord for student Q&A (sustainability TBD)
- [ ] **SITE-06**: Custom domain configured with HTTPS (post-deployment)
- [ ] **SITE-07**: EPUB build finalized with proper styling for Amazon KDP (post-deployment)

---

## Out of Scope

- **Video content** — written format only at launch; streaming/video deferred indefinitely
- **Auto-graded exercises** — self-study resource, no automated grading infrastructure
- **Non-Python code examples** — Python is the primary and only language at launch
- **Academic grading rubrics** — self-study resource, not a for-credit course
- **Multi-cloud deployments** — Cloudflare Pages only at launch
- **Deep ML/AI theory** — backpropagation, training, and fine-tuning are out of scope

---

## Anti-Features

- Passive reading-only sections with no deployable output
- Broken code examples that do not run
- A CI/CD pipeline that does not actually deploy
- Content that requires deep ML theory background to follow