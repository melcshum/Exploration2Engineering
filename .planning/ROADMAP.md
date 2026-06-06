# Roadmap — From Exploration to Engineering

## Phases

- [ ] **Phase 1: Foundation** — Ch1 content polished, mkdocs.yml configured, local build validated
- [ ] **Phase 2: Pipeline** — GitHub Actions CI/CD + Cloudflare Pages deployment live
- [ ] **Phase 3: Polish** — Site production-ready with navigation, EPUB export, live shareable URL
- [ ] **Phase 4: Ch2** — Chapter 2 drafted in tutorial format with deployable LLM project

---

## Phase Details

### Phase 1: Foundation
**Goal:** Ch1 is polished and production-ready; local MkDocs build validated
**Depends on:** Nothing (first phase)
**Requirements:** CONTENT-01, CONTENT-02, CONTENT-03, BUILD-01, BUILD-03
**Success Criteria** (what must be TRUE):
1. Chapter 1 is polished, production-ready, and builds without errors
2. Chapter content follows tutorial format: concept introduced, working code built, deployable artifact produced
3. All code examples are executable Python snippets embedded in chapter markdown
4. `mkdocs build --strict` succeeds locally with no warnings or errors
5. `mkdocs serve` runs for live preview during development
**Plans:** TBD

### Phase 2: Pipeline
**Goal:** CI/CD pipeline automates build and deploy to Cloudflare Pages
**Depends on:** Phase 1
**Requirements:** DEPLOY-01, DEPLOY-02, DEPLOY-03, DEPLOY-04, DEPLOY-05
**Success Criteria** (what must be TRUE):
1. `.github/workflows/deploy.yml` builds MkDocs site on every push to main
2. Workflow uses `cloudflare/wrangler-action@v3` to deploy to Cloudflare Pages
3. `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured as GitHub repository secrets
4. Build command is `mkdocs build --strict` with output directory `site/`
5. Python version is pinned via `.python-version` to prevent silent breakage
**Plans:** TBD

### Phase 3: Polish
**Goal:** Site is production-ready and publicly accessible; EPUB export functional
**Depends on:** Phase 2
**Requirements:** SITE-01, SITE-02, SITE-03, SITE-04, SITE-05, BUILD-02
**Success Criteria** (what must be TRUE):
1. Deployed site is live at a shareable Cloudflare Pages URL
2. MkDocs Material theme is configured with working search, code copy, and navigation
3. `mkdocs.yml` has `edit_url` configured correctly for each chapter
4. Draft documents are excluded from production build
5. Navigation shows all published chapters without broken links
6. `book/build.sh` generates a working EPUB export
**Plans:** TBD

### Phase 4: Ch2
**Goal:** Chapter 2 drafted in tutorial format covering LLM integration patterns
**Depends on:** Phase 3
**Requirements:** CONTENT-04, CONTENT-05
**Success Criteria** (what must be TRUE):
1. Chapter 2 is drafted, follows tutorial format, and covers LLM integration patterns
2. Ch2 builds a deployable project artifact
3. Chapters 3+ are outlined with sufficient depth for multi-chapter curriculum
**Plans:** TBD

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|---------------|--------|-----------|
| 1. Foundation | 0/5 | Not started | - |
| 2. Pipeline | 0/5 | Not started | - |
| 3. Polish | 0/6 | Not started | - |
| 4. Ch2 | 0/3 | Not started | - |