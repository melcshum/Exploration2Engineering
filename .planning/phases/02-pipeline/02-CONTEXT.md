# Phase 2: Pipeline - Context

**Gathered:** 2026-06-06
**Status:** Ready for planning

## Phase Boundary

CI/CD pipeline that builds the MkDocs site and deploys it to Cloudflare Pages on every push to main.

## Implementation Decisions

### Deployment Scope
- **D-01:** Main branch only — no PR preview deployments. Build runs on PRs (CI validation), but only deploys on push to main.
- **D-02:** Phase 1 decision carried forward: `mkdocs build --strict` with output to `site/` root directory.

### Cloudflare Pages Provisioning
- **D-03:** The GitHub Actions workflow provisions the Cloudflare Pages project if it doesn't exist — using `wrangler pages project create` or equivalent.
- **D-04:** Workflow uses `cloudflare/wrangler-action@v3` for deployment (per DEPLOY-02 requirement).
- **D-05:** `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` configured as GitHub repository secrets.

### Wrangler Configuration
- **D-06:** No `wrangler.toml` file — token + account ID passed directly to `wrangler-action`. Simpler, fewer files.

### Artifact Path
- **D-07:** MkDocs build outputs to root-level `site/` directory (not `book/site/`).
- **D-08:** MkDocs `mkdocs.yml` must be configured with `site_dir: ../site` relative to the book/ source root, OR the build command uses `mkdocs build --strict --site-dir ../site` from within the book/ directory.
- **D-09:** Python version is pinned to `3.12` via `book/.python-version` (already created in Phase 1 — DEPLOY-05 satisfied).

### Failure Handling
- **D-10:** Build or deploy failure causes the GitHub Actions job to fail — no email or Slack notification. Failures visible as red X on the commit.

### Build Command
- **D-11:** Build command: `mkdocs build --strict` (per DEPLOY-04 requirement).
- **D-12:** Output directory: `site/` (at repo root, not inside book/).

### What Phase 2 Does NOT Cover (Phase 3 scope)
- Navigation tabs for all published chapters (SITE-05)
- Custom domain with HTTPS (SITE-01 / deferred)
- mkdocs.yml theme customization (SITE-02)
- EPUB build script (BUILD-02)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Configuration
- `book/mkdocs.yml` — current MkDocs config (needs site_dir adjustment for root-level output)
- `book/.python-version` — already created with `3.12` (Phase 1)
- `.github/workflows/deploy.yml` — to be created

### Prior Phase Context
- `.planning/phases/01-foundation/01-CONTEXT.md` — Phase 1 decisions (docs_dir, chapter naming, Python pinning)
- `.planning/ROADMAP.md` — Phase 2 definition (goal, requirements, success criteria)
- `.planning/REQUIREMENTS.md` — Phase 2 requirements: DEPLOY-01, DEPLOY-02, DEPLOY-03, DEPLOY-04, DEPLOY-05

### External References
- [Cloudflare Pages GitHub Actions](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) — Official docs
- [cloudflare/wrangler-action@v3](https://github.com/cloudflare/wrangler-action) — GitHub repo

</canonical_refs>

<codebase_context>
## Existing Code Insights

### From Phase 1
- `book/.python-version` created with `3.12` — DEPLOY-05 satisfied
- `mkdocs.yml` at `book/` root — needs `site_dir` adjustment for root-level output
- Phase 1 decided: `docs_dir: book/docs`, `ch1-ai-supported-software.md` filename

### Integration Points
- Workflow needs to `cd book/` before running `mkdocs build --strict`
- Output `site/` at repo root — wrangler-action deploys from `site/`
- Secrets needed: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`

### Build Pipeline Sequence
1. Checkout repo (actions/checkout@v6)
2. Set up Python 3.12 (uses book/.python-version)
3. Install dependencies (pip install mkdocs-material)
4. Run `mkdocs build --strict` from book/ directory
5. Deploy `site/` to Cloudflare Pages via wrangler-action

</codebase_context>

<specifics>
## Specific Ideas

- User wants main-only deployments (no PR previews) — simpler, no extra cost
- User wants Cloudflare project provisioned by the workflow (not pre-created manually)
- User wants token + account ID only — no wrangler.toml file
- User wants root-level site/ output
- User wants failure to show as GitHub Actions red X only — no notification integrations

</specifics>

<deferred>
## Deferred Ideas

### Phase 3 (Polish)
- Navigation tabs for all published chapters (SITE-05)
- `mkdocs.yml` theme customization — colors, logo (SITE-02)
- `edit_url` fix for chapters (SITE-03)
- Draft exclusion (SITE-04)
- EPUB build script finalization (BUILD-02)
- Custom domain with HTTPS

### Phase 4 (Ch2)
- Chapter 2 content and tutorial format
- Chapters 3+ outline

</deferred>

---
*Phase: 02-Pipeline*
*Context gathered: 2026-06-06*