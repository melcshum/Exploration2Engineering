---
phase: "02"
phase_name: "Pipeline"
project: "Exploration2Engineering"
generated: "2026-06-06"
counts:
  decisions: 6
  lessons: 2
  patterns: 3
  surprises: 2
missing_artifacts:
  - "STATE.md"
---

# Phase 02 Learnings: Pipeline

## Decisions

### wrangler-action v3 over pages-action
**What:** Used `cloudflare/wrangler-action@v3` instead of the deprecated `cloudflare/pages-action`.
**Rationale:** Official Cloudflare docs recommend wrangler-action v3 for flexibility and active maintenance. pages-action is deprecated.
**Source:** 02-01-PLAN.md, 02-01-SUMMARY.md

---

### No wrangler.toml — secrets passed directly
**What:** Passed `apiToken` and `accountId` directly to the wrangler-action instead of creating a `wrangler.toml` file.
**Rationale:** Secrets should not be written to disk in the repo. Passing inputs directly to the action keeps credentials in GitHub's secrets vault only.
**Source:** 02-01-PLAN.md (D-06)

---

### preCommands with `|| true` for idempotent project provisioning
**What:** Used `wrangler pages project create exploration-to-engineering || true` in preCommands.
**Rationale:** The project may or may not exist yet. The `|| true` fallback prevents the workflow from failing if the project was already created in a prior run.
**Source:** 02-01-PLAN.md (D-03), 02-01-SUMMARY.md

---

### Build command `mkdocs build --strict`
**What:** Used `mkdocs build --strict` as the build command in the GitHub Actions workflow.
**Rationale:** `--strict` causes the build to fail on any warning, ensuring CI catches issues before they reach production.
**Source:** 02-01-PLAN.md (D-11), 02-01-SUMMARY.md

---

### site_dir: ../site for root-level output
**What:** Configured `site_dir: ../site` in `book/mkdocs.yml` so MkDocs outputs to repo root `site/` instead of `book/site/`.
**Rationale:** The GitHub Actions workflow runs from the repo root, and wrangler-action deploys the `site/` directory. Without this setting, MkDocs would output to `book/site/` and wrangler-action would deploy an empty directory.
**Source:** 02-01-SUMMARY.md (auto-fixed issue), 02-02-PLAN.md

---

### Python version pinned via python-version-file
**What:** Used `python-version-file: book/.python-version` in setup-python action instead of hardcoding a version string.
**Rationale:** Keeps Python version defined in a repo file (`book/.python-version`) that developers can check and that stays in sync with the local dev setup.
**Source:** 02-01-PLAN.md (DEPLOY-05), 02-01-SUMMARY.md

---

## Lessons

### site_dir is easy to overlook but causes silent wrong behavior
**What:** Without `site_dir: ../site` in `book/mkdocs.yml`, MkDocs outputs to `book/site/` instead of repo root `site/`. The build succeeds but wrangler-action deploys an empty directory.
**Context:** This was a missing critical configuration auto-fixed during plan execution. The workflow built successfully but would have deployed nothing. This is a silent correctness failure — no error is raised, but the site content never appears.
**Source:** 02-01-SUMMARY.md (Deviations section)

---

### Cloudflare credentials require human action to configure
**What:** GitHub repository secrets (CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID) cannot be created by the CI/CD workflow — they require manual human configuration in the GitHub web UI.
**Context:** Plan 02-03 had to be marked as a `checkpoint:human-action` because no automated tool can set secrets. This is a common pattern: credentials and external service configuration often require manual human setup before automation can proceed.
**Source:** 02-03-PLAN.md

---

## Patterns

### GitHub Actions + wrangler-action v3 for Cloudflare Pages deployment
**What:** A standard GitHub Actions workflow that checks out code, sets up Python, installs dependencies, builds MkDocs, and deploys to Cloudflare Pages using `cloudflare/wrangler-action@v3`.
**When to use:** Any MkDocs or static site project deploying to Cloudflare Pages with a GitHub Actions CI/CD pipeline.
**Source:** 02-01-SUMMARY.md (patterns-established)

---

### python-version-file for pinned Python versions in CI
**What:** The setup-python action reads the Python version from a `.python-version` file rather than hardcoding a version string in the workflow YAML.
**When to use:** When the Python version should be single-sourced in a file that both local development and CI can reference.
**Source:** 02-01-SUMMARY.md (patterns-established)

---

### preCommands with `|| true` fallback for idempotent project provisioning
**What:** Wrangler preCommands that run `wrangler pages project create <name> || true` — the `|| true` ensures the command succeeds even if the project already exists.
**When to use:** When a CI/CD pipeline needs to provision infrastructure that may or may not exist yet, without failing on the first run.
**Source:** 02-01-SUMMARY.md (patterns-established)

---

## Surprises

### Missing site_dir was a silent failure, not a loud one
**What:** The missing `site_dir: ../site` would have caused the build to succeed but the deploy to produce an empty site. No error or warning was raised during the build step.
**Impact:** The site would have deployed without any content. This is a dangerous class of failure — automation says "everything is fine" while the actual outcome is completely wrong.
**Source:** 02-01-SUMMARY.md (Deviations section)

---

### CI required ~7 fix commits before first successful deploy
**What:** The CI pipeline failed multiple times before the first successful deploy — missing `.python-version`, missing `requirements.txt` for the CI environment, missing `mkdocs-excalidraw` plugin in `requirements.txt`, wrong working-directory path in workflow steps.
**Impact:** Each failed CI run exposed a missing piece that had to be diagnosed and fixed via git commits. The pipeline required significant iteration to reach a successful state.
**Source:** Prior session working notes

---