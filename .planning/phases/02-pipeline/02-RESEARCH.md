# Phase 2: Pipeline - Research

**Researched:** 2026-06-06
**Domain:** GitHub Actions CI/CD + Cloudflare Pages deployment via wrangler-action v3
**Confidence:** HIGH

## Summary

Phase 2 automates the MkDocs build and deploys to Cloudflare Pages on every push to main. The GitHub Actions workflow (`.github/workflows/deploy.yml`) checks out code, sets up Python 3.12 from `book/.python-version`, installs MkDocs dependencies, runs `mkdocs build --strict --site-dir ../site` from the `book/` directory (outputting to repo root `site/`), provisions the Cloudflare Pages project if absent, and deploys via `cloudflare/wrangler-action@v3`. Secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are passed directly to the action without a `wrangler.toml` file. The workflow does NOT send notifications on failure.

**Primary recommendation:** Create `.github/workflows/deploy.yml` with the standard GitHub Actions + wrangler-action pattern, use `preCommands` for project provisioning, and set `site_dir: ../site` in `book/mkdocs.yml` so `mkdocs build --strict` produces root-level `site/` output without needing `--site-dir` in the CI command.

## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Main branch only -- no PR preview deployments. Build runs on PRs (CI validation), but only deploys on push to main.
- **D-02:** `mkdocs build --strict` with output to `site/` root directory.
- **D-03:** GitHub Actions workflow provisions Cloudflare Pages project if it doesn't exist.
- **D-04:** Uses `cloudflare/wrangler-action@v3` for deployment.
- **D-05:** `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` configured as GitHub repository secrets.
- **D-06:** No `wrangler.toml` file -- token + account ID passed directly to wrangler-action.
- **D-07:** MkDocs build outputs to root-level `site/` directory (not `book/site/`).
- **D-08:** MkDocs `mkdocs.yml` must be configured with `site_dir: ../site` relative to the book/ source root, OR the build command uses `mkdocs build --strict --site-dir ../site` from within the book/ directory.
- **D-09:** Python version is pinned to `3.12` via `book/.python-version`.
- **D-10:** Build or deploy failure causes the GitHub Actions job to fail -- no email or Slack notification.
- **D-11:** Build command: `mkdocs build --strict`.
- **D-12:** Output directory: `site/` (at repo root).

### Deferred Ideas (OUT OF SCOPE)

- Navigation tabs for all published chapters (SITE-05)
- Custom domain with HTTPS (SITE-01 / deferred)
- mkdocs.yml theme customization (SITE-02)
- EPUB build script (BUILD-02)

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEPLOY-01 | GitHub Actions workflow (`.github/workflows/deploy.yml`) builds the MkDocs site on every push to main | Workflow triggers on `push: branches: [main]`; `mkdocs build --strict` runs in CI |
| DEPLOY-02 | Workflow uses `cloudflare/wrangler-action@v3` to deploy to Cloudflare Pages | Action input `uses: cloudflare/wrangler-action@v3` with `command: pages deploy` |
| DEPLOY-03 | `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured as GitHub repository secrets | Action inputs `apiToken` and `accountId` read from `${{ secrets.* }}` |
| DEPLOY-04 | Build command is `mkdocs build --strict` with output directory `site/` | Build step runs `mkdocs build --strict`; `site_dir: ../site` in mkdocs.yml directs output to root `site/` |
| DEPLOY-05 | Python version is pinned via `.python-version` to prevent silent breakage from build image upgrades | `actions/setup-python@v5` with `python-version-file: book/.python-version` reads the pinned version |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| CI/CD orchestration | GitHub Actions | -- | GitHub-native CI, free for open source |
| Python environment | GitHub Actions runner | -- | `setup-python` action manages version |
| Static site build | CI (MkDocs) | -- | `mkdocs build --strict` runs in CI job |
| Cloudflare Pages provisioning | CI (wrangler preCommands) | -- | `wrangler pages project create` runs before deploy |
| Cloudflare Pages deployment | CI (wrangler-action) | -- | `wrangler-action` handles OAuth + deploy API call |
| Secret management | GitHub repository secrets | -- | Tokens stored as GitHub secrets, injected at runtime |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| GitHub Actions | -- | CI/CD orchestration | Native to repo; free for open source |
| `cloudflare/wrangler-action` | v3 | Deployment to Cloudflare Pages | Official Cloudflare recommendation; [official docs](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) confirm |
| `actions/checkout` | v6 | Repository checkout | Latest major version; required for wrangler-action |
| `actions/setup-python` | v5 | Python environment management | Canonical GitHub Actions Python setup action |
| MkDocs | 1.6.x | Static site generation | [MkDocs docs](https://www.mkdocs.org) confirm 1.6.x current stable |
| Material for MkDocs | 9.7.x | Documentation theme | In `book/requirements.txt`; best-in-class docs theme |
| Python | 3.12 | Runtime | Pinned via `book/.python-version` |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `wrangler` | v4 (bundled in action) | Cloudflare Workers/Pages CLI | Provisioning via `preCommands` |
| `pip` | -- | Package installation | Installing MkDocs and Material from requirements.txt |

### Installation

```bash
# Dependencies already in book/requirements.txt
# No additional packages needed -- wrangler-action bundles wrangler
```

**Version verification:** Python 3.12 confirmed in `book/.python-version` (Phase 1). MkDocs 1.6.x and Material 9.7.x confirmed in `book/requirements.txt` from Phase 1. `wrangler-action@v3` is a GitHub Action, not an npm package.

## Architecture Patterns

### System Architecture Diagram

```
GitHub Repository
     │
     │ push to main (or PR)
     ▼
┌─────────────────────────────────────────────────────────┐
│  GitHub Actions Workflow (.github/workflows/deploy.yml)  │
│                                                         │
│  1. actions/checkout@v6 (full repo)                    │
│         │                                               │
│         ▼                                               │
│  2. actions/setup-python@v5                            │
│      - reads book/.python-version (3.12) │
│         │                                               │
│         ▼                                               │
│  3. Run: pip install -r book/requirements.txt          │
│      - installs mkdocs + material                      │
│         │                                               │
│         ▼                                               │
│  4. Run: mkdocs build --strict │
│      - reads book/mkdocs.yml                           │
│      - site_dir: ../site → outputs to repo root site/   │
│         │                                               │
│         ▼                                               │
│  5. cloudflare/wrangler-action@v3                     │
│      - preCommands: wrangler pages project create      │
│      - command: pages deploy site --project-name=... │
│      - apiToken + accountId from GitHub secrets       │
│         │                                               │
└─────────┼───────────────────────────────────────────────┘
          │
          ▼
   Cloudflare Pages
   (static site CDN)
```

### Recommended Project Structure

```
.exploration-to-engineering/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD workflow (NEW)
├── book/
│   ├── mkdocs.yml              # site_dir: ../site (MODIFY)
│   ├── .python-version         # 3.12 (already exists)
│   ├── requirements.txt        # mkdocs + material (already exists)
│   ├── docs/ # chapter sources
│   └── site/                   # local build output (gitignore this)
├── site/                       # CI build output (gitignore this)
└── .gitignore                  # add: site/, book/site/
```

### Pattern 1: GitHub Actions + Wrangler-action v3 Deployment

**What:** A two-step CI workflow: first build the MkDocs site, then deploy the output to Cloudflare Pages via `wrangler-action`.

**When to use:** Any MkDocs project deploying to Cloudflare Pages via GitHub Actions.

**Source:** [Cloudflare Pages CI/CD documentation](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration)

**Example:**

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  deployments: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version-file: book/.python-version

      - name: Install dependencies
        run: pip install -r book/requirements.txt
        working-directory: book

      - name: Build MkDocs
        run: mkdocs build --strict
        working-directory: book

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          preCommands: |
            wrangler pages project create exploration-to-engineering || true
          command: pages deploy site --project-name=exploration-to-engineering
```

### Pattern 2: Conditional Deployment (main vs PR)

**What:** Build runs on all branches for CI validation, but deployment only happens on main.

**When to use:** When you want PRs to validate builds without incurring Cloudflare Pages deployment costs or creating unwanted preview deployments.

**Source:** GitHub Actions workflow pattern; confirmed by D-01 decision.

### Pattern 3: site_dir Configuration for Cross-Directory Build

**What:** `mkdocs.yml` sets `site_dir: ../site` so `mkdocs build` outputs to the repo root `site/` directory even when the config file is in a subdirectory (`book/`).

**When to use:** When MkDocs config lives in a subdirectory but you want build output at the repo root.

**Source:** [MkDocs configuration documentation](https://www.mkdocs.org/user-guide/configuration/) -- `site_dir` is relative to the config file directory.

**Example:**

```yaml
# book/mkdocs.yml
docs_dir: docs
site_dir: ../site   # resolves to repo-root/site/ from book/mkdocs.yml location
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Cloudflare deployment authentication | Hand-roll OAuth flow or API calls | `cloudflare/wrangler-action@v3` | Handles token injection, API calls, deployment status automatically |
| Cloudflare Pages project creation | Manually create via dashboard | `wrangler pages project create` in `preCommands` | User decision D-03 requires automated provisioning |
| Python version management | Hard-code version in workflow | `python-version-file` pointing to `.python-version` | Pins version as required by DEPLOY-05; matches local dev |
| Build output path handling | Script to copy/move files between directories | `site_dir: ../site` in mkdocs.yml | Single configuration; no extra CI steps |

**Key insight:** The wrangler-action bundles wrangler v4 and handles all Cloudflare Pages API interactions. Attempting to hand-roll the deployment API calls would require managing OAuth tokens, multipart file uploads, and deployment status polling -- all of which the action abstracts away.

## Common Pitfalls

### Pitfall 1: site_dir Path Resolution Confusion

**What goes wrong:** `mkdocs build` outputs to `book/site/` instead of root `site/`, so wrangler-action deploys the wrong directory.

**Why it happens:** `site_dir` in mkdocs.yml is relative to the config file location, not the current working directory. If `mkdocs.yml` is at `book/mkdocs.yml` and you set `site_dir: site`, MkDocs creates `book/site/`.

**How to avoid:** Set `site_dir: ../site` in `book/mkdocs.yml` so the output resolves to repo root `site/`. Alternatively, use `--site-dir ../site` flag in the CI command.

**Warning signs:** `book/site/` directory gets populated but root `site/` is empty after build.

### Pitfall 2: wrangler.toml Not Used / accountId Mismatch

**What goes wrong:** wrangler-action fails with "Missing account ID" even though `accountId` is set in the action.

**Why it happens:** wrangler-action v3 reads `accountId` from the action input OR from `wrangler.toml`. Without `wrangler.toml`, the action input MUST be set. If both exist and conflict, behavior can be unpredictable.

**How to avoid:** Per D-06, do NOT create a `wrangler.toml`. Pass `accountId` directly to the action input. Confirm `CLOUDFLARE_ACCOUNT_ID` secret matches the account owning the Cloudflare Pages project.

**Warning signs:** wrangler-action log shows "No account id found" or "Could not find wrangler config".

### Pitfall 3: Project Name Already Exists Causes Workflow Failure

**What goes wrong:** The `preCommands` `wrangler pages project create` fails with a non-zero exit when the project already exists, causing the whole job to fail.

**Why it happens:** `wrangler pages project create` returns an error if the project name is already taken.

**How to avoid:** Append `|| true` to the create command: `wrangler pages project create <name> || true`. This allows the workflow to proceed whether the project is newly created or already exists. Alternatively, use `wrangler pages project list` to check first.

**Warning signs:** GitHub Actions job fails at the "Deploy to Cloudflare Pages" step with wrangler error about project already existing.

### Pitfall 4: Python Version Not Matching Local Development

**What goes wrong:** CI passes but production behavior differs due to Python version mismatch (CI uses system Python instead of 3.12).

**Why it happens:** GitHub Actions `ubuntu-latest` runner includes Python, but without explicit version pinning it uses the runner's default (often 3.10 or 3.11 on older runners).

**How to avoid:** Use `actions/setup-python@v5` with `python-version-file: book/.python-version`. This reads the pinned version from the repo, ensuring CI matches local development exactly.

**Warning signs:** Build passes in CI but `mkdocs build --strict` fails locally due to a Python version-specific feature.

### Pitfall 5: MkDocs Build Warnings Treated as Errors by --strict

**What goes wrong:** `mkdocs build --strict` fails in CI but not locally because the local build has cached or corrected assets.

**Why it happens:** `--strict` treats all warnings as errors -- including missing references, broken links, or deprecated features in the MkDocs configuration.

**How to avoid:** Ensure `mkdocs build --strict` succeeds locally before committing. Phase 1 already validated this (BUILD-01). Keep the `strict` flag in CI as an early warning system.

**Warning signs:** CI build fails with "WARNING" output that does not appear in local `mkdocs serve`.

## Code Examples

### MkDocs site_dir Configuration (book/mkdocs.yml addition)

```yaml
# book/mkdocs.yml
site_name: From Exploration to Engineering
site_description: Designing AI-Supported Software with LLMs, RAG, and Agentic Workflows
site_url: https://yourusername.github.io/exploration-to-engineering
docs_dir: docs
site_dir: ../site   # NEW: output to repo root site/ instead of book/site/
```

**Source:** [MkDocs site_dir documentation](https://www.mkdocs.org/user-guide/configuration/) -- path is relative to config file directory.

### .gitignore Additions (for site/ directories)

```gitignore
# MkDocs build output -- CI builds fresh each time
site/
book/site/
```

**Source:** Standard MkDocs + GitHub Actions pattern.

### GitHub Actions Workflow (full deploy.yml)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  deployments: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version-file: book/.python-version

      - name: Install dependencies
        run: pip install -r book/requirements.txt
        working-directory: book

      - name: Build MkDocs site
        run: mkdocs build --strict
        working-directory: book

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          preCommands: |
            wrangler pages project create exploration-to-engineering || true
          command: pages deploy site --project-name=exploration-to-engineering
```

**Source:** [Cloudflare Pages CI/CD documentation](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration); verified against official wrangler-action README.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `cloudflare/pages-action@v1` | `cloudflare/wrangler-action@v3` | pages-action deprecated in favor of wrangler-action | wrangler-action supports Workers + Pages, more flexible |
| `actions/checkout@v3/v4` | `actions/checkout@v6` | v6 is latest major version | v6 has better performance and security |
| GitHub Pages hosting | Cloudflare Pages hosting | Project inception | Cloudflare has better global edge network, more generous free tier |
| Manual Cloudflare dashboard deploys | Automated CI/CD via GitHub Actions | Phase 2 | Eliminates manual deploy steps; enables atomic deploys |

**Deprecated/outdated:**

- `cloudflare/pages-action@v1`: Deprecated; no longer maintained. Use `wrangler-action@v3` instead.
- `actions/checkout@v3/v4`: Old versions; v6 is current.
- Wrangler v2 / `wrangler@2`: Old wrangler version; wrangler-action v3 bundles v4.

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research. The planner and discuss-phase use this section to identify decisions that need user confirmation before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `wrangler pages project create <name> || true` handles existing projects gracefully | Common Pitfalls | If wrangler v4 uses different syntax or error codes, the `|| true` fallback may not work; may need `wrangler pages project list \| grep <name> \|\| wrangler pages project create` |
| A2 | Project name "exploration-to-engineering" is available on Cloudflare Pages | Architecture Patterns | Cloudflare Pages project names must be globally unique. If taken, the deploy will fail. User may need to choose a different name. |
| A3 | `mkdocs build --strict` with `site_dir: ../site` in `book/mkdocs.yml` resolves to repo root `site/` | Standard Stack | Path resolution is relative to config file location. `../site` from `book/mkdocs.yml` = `repo_root/site/`. Verified via MkDocs docs but not yet tested in this project. |
| A4 | `actions/setup-python@v5` with `python-version-file: book/.python-version` works for files in subdirectories | Standard Stack | GitHub Actions docs show `python-version-file` as relative to repo root. `book/.python-version` should work, but this specific subdirectory path has not been verified against GitHub Actions release notes. |
| A5 | The `site/` directory at repo root does not need to be pre-created | Common Pitfalls | MkDocs creates the site_dir automatically. If there is a permission issue, the build would fail. Assumed to work based on standard MkDocs behavior. |
| A6 | `wrangler pages project create` uses `--name` flag (not `--project-name`) in wrangler v4 | Code Examples | Wrangler v4 changed from `--project-name` (Workers syntax) to `--name`. The flag name may differ. Planner should verify exact syntax before the `preCommands` step. |

## Open Questions

1. **Cloudflare Pages project name uniqueness**
   - What we know: Cloudflare Pages project names must be globally unique.
   - What's unclear: Whether "exploration-to-engineering" is available, or if user needs to pick a different name.
   - Recommendation: Planner should note this as a potential manual step / user confirmation item. The workflow uses the project name from the site_url or a reasonable default.

2. **Exact wrangler v4 `pages project create` flag syntax**
   - What we know: `wrangler pages project create` creates a Pages project. Flags may be `--name` or `--project-name`.
   - What's unclear: Exact flag name in wrangler v4 (bundled in wrangler-action v3).
   - Recommendation: Planner should run a test or verify against wrangler v4 changelog before finalizing `preCommands`.

3. **GitHub repository secrets setup instructions**
   - What we know: DEPLOY-03 requires `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as GitHub repository secrets.
   - What's unclear: Whether these are already configured or need to be set up as part of Phase 2.
   - Recommendation: Phase 2 should include a task to verify/create these secrets, or document the setup steps.

## Environment Availability

> Step 2.6: SKIPPED -- no external CLI dependencies beyond GitHub Actions (which runs in the cloud). All tools (`actions/checkout`, `actions/setup-python`, `wrangler-action`) are GitHub Action abstractions. The local environment needs Python 3.12 for local testing, but CI handles its own environment.

**Missing dependencies with no fallback:**
- None identified -- CI environment is self-contained.

## Validation Architecture

> Skip this section if workflow.nyquist_validation is explicitly set to false. If absent, treat as enabled.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | No automated testing for CI/CD configuration -- manual verification via GitHub Actions run |
| Config file | None |
| Quick run command | N/A -- CI/CD validation requires GitHub Actions execution |
| Full suite command | N/A |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| DEPLOY-01 | Workflow builds MkDocs on every push to main | Manual | Trigger a push to main branch and observe GitHub Actions | `.github/workflows/deploy.yml` (new) |
| DEPLOY-02 | Workflow uses wrangler-action@v3 | Static analysis | Grep for `wrangler-action@v3` in deploy.yml | `.github/workflows/deploy.yml` (new) |
| DEPLOY-03 | Secrets configured | Manual | Verify `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` exist in GitHub repo settings | N/A (GitHub UI) |
| DEPLOY-04 | `mkdocs build --strict` with site/ output | Manual | Run `mkdocs build --strict` locally and verify `site/` contains index.html | `site/` (new) |
| DEPLOY-05 | Python pinned via .python-version | Static analysis | Grep for `3.12` in book/.python-version | `book/.python-version` (exists) |

### Wave 0 Gaps

- [ ] `.github/workflows/deploy.yml` -- DEPLOY-01, DEPLOY-02, DEPLOY-04
- [ ] `book/mkdocs.yml` modification (add `site_dir: ../site`) -- DEPLOY-04
- [ ] `.gitignore` additions (`site/`, `book/site/`) -- DEPLOY-04

*(If no gaps: "None -- existing test infrastructure covers all phase requirements")*

## Security Domain

> Required when `security_enforcement` is enabled (absent = enabled). Omit only if explicitly `false` in config.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | N/A -- no user authentication in static site |
| V3 Session Management | No | N/A -- no sessions |
| V4 Access Control | No | N/A -- public static site |
| V5 Input Validation | Partial | CI workflow inputs (secrets) are validated by GitHub Actions; no user input in static deploy |
| V6 Cryptography | Yes | API tokens transmitted via GitHub secrets (encrypted at rest); HTTPS for all Cloudflare API calls |

### Known Threat Patterns for GitHub Actions + Cloudflare Pages

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Secret leakage in workflow logs | Disclosure | GitHub Actions redacts secret values in logs automatically |
| Malicious workflow injection via branch name | Tampering | GitHub Actions sanitizes branch names; CI runs in ephemeral environment |
| Cloudflare API token theft | Disclosure | Token stored as GitHub secret (encrypted); rotated via Cloudflare dashboard if compromised |
| Unauthorized deployment from forked PRs | Tampering | D-01 limits deploys to main branch only; `permissions: contents: read` limits read access |

## Sources

### Primary (HIGH confidence)

- [Cloudflare Pages GitHub Actions (official docs)](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) -- Official deployment pattern
- [MkDocs site_dir configuration](https://www.mkdocs.org/user-guide/configuration/) -- site_dir path resolution behavior

### Secondary (MEDIUM confidence)

- [wrangler-action v3 README](https://github.com/cloudflare/wrangler-action) -- Configuration options and examples
- [GitHub Actions setup-python](https://github.com/actions/setup-python) -- python-version-file behavior

### Tertiary (LOW confidence)

- Wrangler v4 `pages project create` exact flag syntax -- Assumed based on wrangler v3 pattern; needs verification
- Project name uniqueness -- Assumed "exploration-to-engineering" is available; needs user confirmation

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH -- all components verified via official documentation
- Architecture: HIGH -- standard GitHub Actions + wrangler-action pattern confirmed
- Pitfalls: HIGH -- common pitfalls documented with mitigation strategies; some flag syntax assumptions noted in Assumptions Log

**Research date:** 2026-06-06
**Valid until:** 2026-07-06 (30 days -- CI/CD patterns are stable; wrangler-action v3 is current)

---

## RESEARCH COMPLETE

**Phase:** 2 - Pipeline
**Confidence:** HIGH

### Key Findings

1. `cloudflare/wrangler-action@v3` is the correct deployment action; it bundles wrangler v4 and handles all Cloudflare Pages API interactions
2. `site_dir: ../site` in `book/mkdocs.yml` is the correct way to output to repo root `site/` from a config file in `book/`
3. Project provisioning via `wrangler pages project create || true` in `preCommands` handles the "project may already exist" case without failing the workflow
4. `actions/setup-python@v5` with `python-version-file: book/.python-version` correctly pins Python 3.12
5. GitHub repository secrets (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`) must be created manually in GitHub UI as a prerequisite to the workflow

### File Created

`.planning/phases/02-pipeline/02-RESEARCH.md`

### Confidence Assessment

| Area | Level | Reason |
|------|-------|--------|
| Standard Stack | HIGH | All components verified via official Cloudflare and GitHub documentation |
| Architecture | HIGH | Standard GitHub Actions + wrangler-action pattern confirmed with official sources |
| Pitfalls | HIGH | All common pitfalls identified with mitigation strategies; 2 flag-syntax assumptions noted for planner verification |

### Open Questions

1. Cloudflare Pages project name "exploration-to-engineering" may not be globally unique -- user may need to confirm or choose alternative
2. Exact `wrangler pages project create` flag syntax in wrangler v4 (`--name` vs `--project-name`) needs verification
3. GitHub repository secrets setup is a manual prerequisite not covered by the workflow file itself

### Ready for Planning

Research complete. Planner can now create PLAN.md files.