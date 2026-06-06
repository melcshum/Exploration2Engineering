# Research Summary: From Exploration to Engineering

**Project:** Technical textbook on AI-supported software development
**Synthesized:** 2026-06-06
**Overall Confidence:** MEDIUM-HIGH

---

## Executive Summary

This is a technical book project that teaches AI-supported development through project-based learning. The book follows a "learn by building" format where each chapter produces a deployable artifact, integrated with AI tools and CI/CD pipelines. The recommended approach uses MkDocs with Material for MkDocs as the documentation framework, GitHub Actions for CI/CD, and Cloudflare Pages for hosting. The project builds a static site from Markdown source, with optional EPUB export via Pandoc.

The technology stack is well-established and low-risk: MkDocs 1.6.x + Material for MkDocs 9.7.x, Python 3.12, and `cloudflare/wrangler-action@v3` for deployment. The architecture is a simple linear pipeline: content authored in Markdown, validated via local build, automated through GitHub Actions, and deployed to Cloudflare Pages CDN. The critical path runs through content creation, local build validation, CI/CD setup, and Cloudflare Pages integration -- in that order.

Key risks center on deployment configuration (wrong build commands, missing secrets, Node.js version mismatches) and content management (draft files appearing in production, broken edit links). These are all preventable with proper configuration and phase-appropriate testing.

---

## Key Findings

### From STACK.md

| Component | Technology | Version | Rationale |
|-----------|------------|---------|-----------|
| Documentation framework | MkDocs | 1.6.x | Python-native, proven, built-in gh-deploy |
| Theme | Material for MkDocs | 9.7.x | Best-in-class; search, nav, code highlighting |
| Runtime | Python | 3.12 | Latest stable; MkDocs 1.6+ requires 3.8+ |
| CI/CD | GitHub Actions | -- | Native to repo; free for open source |
| Deployment | cloudflare/wrangler-action | v3 | Official Cloudflare recommendation; more flexible than pages-action |
| Checkout | actions/checkout | v6 | Better performance and security |

**Critical configuration:** Use `mkdocs build` as build command and `site` as build directory for Cloudflare Pages.

### From FEATURES.md

**Table stakes (must-have):**
- Working, runnable Python code examples (students need executable code immediately)
- Progressive skill building from basics to advanced projects
- End-of-chapter exercises with solutions or answer keys
- Each chapter produces a deployable artifact
- GitHub Actions + Cloudflare Pages CI/CD demonstrated end-to-end

**Differentiators:**
- Deployment pipeline in every chapter (students get live URLs to share)
- AI tool integration embedded throughout (not a separate module)
- Job-readiness context (resume-worthy projects, interview prep)
- Anti-patterns and failure modes discussed

**Anti-features (explicitly avoid):**
- Academic grading rubrics (out of scope; kills self-study motivation)
- Video content at launch (high production cost, delays publication)
- Non-Python code examples (fragmented learning)
- Passive reading only (every section needs action: read -> build -> deploy)
- Deep ML theory without practical application

### From ARCHITECTURE.md

**Component boundaries:**
1. **Content source** (`docs/`) -- Markdown files with YAML front matter
2. **Site configuration** (`mkdocs.yml`) -- Theme, nav, plugins, metadata
3. **Build engine** (`mkdocs build`) -- Transforms Markdown + config to static HTML
4. **CI/CD pipeline** (`.github/workflows/deploy.yml`) -- Checkout, build, validate, deploy
5. **Hosting** (Cloudflare Pages) -- Static file serving, CDN, HTTPS

**Data flow:** One-way only. Content authored in Markdown -> validated via local build -> automated through GitHub Actions -> deployed to Cloudflare Pages. No database, no user-generated content, no authentication.

**Phase order (critical path):**
1. Content (`docs/`) + `mkdocs.yml` -- All publishing derives from these
2. Local build validation -- Verify site renders correctly before automating
3. GitHub Actions workflow -- Automate with CI; adds link validation
4. Cloudflare Pages integration -- Connect CI output to hosting
5. Custom domain + HTTPS -- After verifying basic deployment works
6. EPUB build (`build.sh`) -- Independent artifact; does not affect site deployment

### From PITFALLS.md

**Critical pitfalls (must prevent):**
1. Missing `search` plugin when explicitly defining plugins -- must include `- search` explicitly
2. Wrong build command for MkDocs -- use `mkdocs build` (not npm-style)
3. Wrangler requires Node.js 16.17.0+ -- pin Node.js version in workflow
4. Missing Cloudflare API token permissions -- token needs Account > Cloudflare Pages > Edit
5. Build image version upgrades breaking builds -- pin Python/Node.js via `.python-version` and `.nvmrc`
6. Draft files appearing in production -- use `draft_docs` option, not `exclude_docs`
7. Edit links redirecting to GitHub login -- use `edit_uri: blob/main/docs/`

**Moderate pitfalls:**
- Build cache not purging on persistent failures (clear via dashboard)
- Subdirectory hosting without updating `site_url` (CSS/JS break)
- Triggering on every push without branch filters (burns CI minutes)
- Missing output directory in Wrangler command (deploys empty directory)

**Minor pitfalls:**
- Build skipping uses `[CF-Pages-Skip]`, not `[CI skip]`
- YAML indentation errors in plugin configuration

---

## Implications for Roadmap

### Suggested Phase Structure

**Phase 1: Content Foundation**
- Create and organize chapter content in `docs/`
- Configure `mkdocs.yml` with navigation, theme, and plugins
- **Why first:** All publishing derives from content and config; MkDocs fails without valid config
- **Delivers:** Structure for all future chapters
- **Pitfalls to avoid:** Missing `search` plugin, draft_docs configuration

**Phase 2: Local Build Validation**
- Verify `mkdocs build --strict` runs successfully
- Test that site renders correctly locally
- **Why after content:** Catch broken links and missing references before CI
- **Delivers:** Validated build process
- **Pitfalls to avoid:** YAML indentation errors, missing asset paths

**Phase 3: CI/CD Pipeline**
- Create `.github/workflows/deploy.yml`
- Configure GitHub Secrets (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`)
- Test deployment from feature branch
- **Why after local build:** CI adds value once local build works
- **Delivers:** Automated build and deploy on push to main
- **Pitfalls to avoid:** Wrong build command (`mkdocs build`), missing output directory, branch filters missing, Node.js version not pinned

**Phase 4: Cloudflare Pages Integration**
- Connect GitHub Actions to Cloudflare Pages project
- Verify live site at `.pages.dev` domain
- **Why after CI:** Deployment requires working pipeline
- **Delivers:** Publicly accessible site
- **Pitfalls to avoid:** API token permissions, build cache corruption, version upgrades breaking builds

**Phase 5: Custom Domain + EPUB**
- Configure custom domain with HTTPS
- Finalize `build.sh` for EPUB export
- **Why last:** After verifying basic deployment works
- **Delivers:** Branded URL and e-book artifact

### Research Flags

| Phase | Needs Research | Notes |
|-------|----------------|-------|
| Phase 1 | No | MkDocs structure is well-documented |
| Phase 2 | No | Local build pattern is standard |
| Phase 3 | MEDIUM | GitHub Actions + Cloudflare integration well-documented via official docs; some ecosystem quirks (skip syntax, cache) benefit from validation |
| Phase 4 | LOW | Cloudflare Pages has comprehensive docs; some cache/version issues benefit from deeper research during planning |
| Phase 5 | No | Custom domain and EPUB patterns are standard |

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| **Stack** | HIGH | Official docs confirmed; version numbers verified via Context7 |
| **Features** | MEDIUM | Market research from adjacent products (Codecademy, freeCodeCamp, Test-Driven.io); some inference involved |
| **Architecture** | MEDIUM | MkDocs structure well-documented; GitHub Actions + Cloudflare Pages details from official docs |
| **Pitfalls** | MEDIUM-HIGH | Official docs confirmed for critical items; some ecosystem patterns from mkdocs-material GitHub |

**Gaps identified:**
- EPUB build (`build.sh`) details not fully validated -- stub exists but chapter files referenced do not exist yet
- Real-world CI/CD behavior on Cloudflare Pages (cache behavior, version upgrade timing) not empirically tested
- Student feedback on feature prioritization would improve confidence in differentiators vs. table stakes

---

## Sources

Research synthesized from:
- [MkDocs Installation & Deployment](https://github.com/mkdocs/mkdocs/wiki/Mkdocs-Deployments) -- Context7 verified
- [Material for MkDocs 9.x](https://github.com/squidfunk/mkdocs-material) -- Context7 verified
- [Cloudflare Pages GitHub Actions](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration/) -- Official docs
- [Cloudflare Pages Build Configuration](https://developers.cloudflare.com/pages/configuration/build-configuration/) -- Official docs
- [Cloudflare Pages Build Image](https://developers.cloudflare.com/pages/configuration/build-image/) -- Official docs
- [Codecademy AI-powered learning features](https://www.codecademy.com/pro/membership)
- [freeCodeCamp certification approach](https://www.freecodecamp.org/news/about/)
- [Test-Driven.io Python courses](https://testdriven.io/courses/)
- [Real Python learning platform](https://realpython.com/)
- [Manning Programming Collective Intelligence](https://www.manning.com/books/programming-collective-intelligence)
