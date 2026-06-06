# Phase 2: Pipeline - Validation

**Phase:** 2
**Generated:** 2026-06-06
**Purpose:** Nyquist-compliant validation architecture mapping DEPLOY requirements to automated commands

---

## Validation Philosophy

Validation uses automated commands wherever possible, with manual checkpoints for requirements that require human interaction or external state (e.g., GitHub Secrets, live Cloudflare Pages deploy).

**Automated** = CLI command that returns pass/fail deterministically
**Manual** = Human action required to verify

---

## Requirement to Command Map

| Req ID | Requirement | Validation Method | Automated Command | Manual Checkpoint |
|--------|-------------|-------------------|-------------------|-------------------|
| DEPLOY-01 | Workflow triggers on push to main | Automated | `grep -q "push.*branches.*main" .github/workflows/deploy.yml && echo PASS` | -- |
| DEPLOY-01 | Build runs on PRs (CI validation, no deploy) | Automated | `grep -q "pull_request.*branches.*main" .github/workflows/deploy.yml && echo PASS` | -- |
| DEPLOY-02 | Workflow uses `cloudflare/wrangler-action@v3` | Automated | `grep -q "wrangler-action@v3" .github/workflows/deploy.yml && echo PASS` | -- |
| DEPLOY-03 | Secrets configured in GitHub repo | Manual | -- | Visit GitHub repo Settings > Secrets and verify `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` exist |
| DEPLOY-04 | Build command is `mkdocs build --strict` | Automated | `grep -q "mkdocs build --strict" .github/workflows/deploy.yml && echo PASS` | -- |
| DEPLOY-04 | site_dir configured for root `site/` output | Manual | -- | Verify `book/mkdocs.yml` contains `site_dir: ../site` |
| DEPLOY-05 | Python version pinned via `book/.python-version` | Automated | `grep -q "^3\.12$" book/.python-version && echo PASS` | -- |
| DEPLOY-05 | setup-python action reads pinned version | Automated | `grep -q "python-version-file.*book/.python-version" .github/workflows/deploy.yml && echo PASS` | -- |

---

## Quick Validation Command

Run all automated checks for Phase 2:

```bash
# DEPLOY-01: push trigger
grep -q "push.*branches.*main" .github/workflows/deploy.yml || { echo "FAIL: DEPLOY-01 push trigger missing"; exit 1; }

# DEPLOY-01: PR trigger
grep -q "pull_request.*branches.*main" .github/workflows/deploy.yml || { echo "FAIL: DEPLOY-01 PR trigger missing"; exit 1; }

# DEPLOY-02: wrangler-action v3
grep -q "wrangler-action@v3" .github/workflows/deploy.yml || { echo "FAIL: DEPLOY-02 wrangler-action@v3 missing"; exit 1; }

# DEPLOY-04: mkdocs build --strict
grep -q "mkdocs build --strict" .github/workflows/deploy.yml || { echo "FAIL: DEPLOY-04 build command missing"; exit 1; }

# DEPLOY-05: Python pinned to 3.12
grep -q "^3\.12$" book/.python-version || { echo "FAIL: DEPLOY-05 Python version not pinned to 3.12"; exit 1; }

# DEPLOY-05: setup-python uses python-version-file
grep -q "python-version-file.*book/.python-version" .github/workflows/deploy.yml || { echo "FAIL: DEPLOY-05 python-version-file not configured"; exit 1; }

echo "PASS: All automated checks passed"
```

---

## Manual Checkpoint Checklist

Before marking Phase 2 complete, verify these manually:

- [ ] **DEPLOY-03:** GitHub repo has `CLOUDFLARE_API_TOKEN` secret configured
- [ ] **DEPLOY-03:** GitHub repo has `CLOUDFLARE_ACCOUNT_ID` secret configured
- [ ] **DEPLOY-04:** `book/mkdocs.yml` contains `site_dir: ../site`

---

## Post-Deploy Validation

After first successful GitHub Actions run:

- [ ] GitHub Actions workflow appears in repo Actions tab
- [ ] Workflow run shows green checkmark for "Deploy to Cloudflare Pages"
- [ ] Cloudflare Pages dashboard shows deployed site with correct content
- [ ] Site is accessible at Cloudflare Pages URL

---

## File Inventory

| File | Purpose | Created By |
|------|---------|------------|
| `.github/workflows/deploy.yml` | CI/CD workflow | Plan 02-01 |
| `book/mkdocs.yml` | site_dir config | Plan 02-02 |
| `.gitignore` | site/ exclusions | Plan 02-02 |
| N/A | GitHub Secrets | Manual (human) |

---

## Validation Complete

This file documents the validation architecture for Phase 2. All automated commands are listed above. Manual checkpoints require human verification before the phase can be marked complete.
