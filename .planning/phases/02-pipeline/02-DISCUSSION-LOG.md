# Phase 2: Pipeline - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-06
**Phase:** 02-Pipeline
**Areas discussed:** PR previews, Cloudflare setup, wrangler config, artifact path, failure handling

---

## PR Preview Deployments

| Option | Description | Selected |
|--------|-------------|----------|
| Main branch only | Deploy only on push to main; build runs on PRs but no deploy | ✓ |
| Every PR gets a preview URL | Preview URL on every PR for reviewer feedback | |
| Every commit (including branches) | Deploy on every branch push | |

**User's choice:** Main branch only (Recommended)
**Notes:** Simpler, no extra cost. PRs still trigger build for CI validation.

---

## Cloudflare Pages Project Setup

| Option | Description | Selected |
|--------|-------------|----------|
| Already created | Use an existing Cloudflare Pages project | |
| Provision it now | Create a new Cloudflare Pages project as part of this phase | ✓ |
| Provision via wrangler CLI in the workflow | Have GitHub Actions create the project if it doesn't exist | |

**User's choice:** Provision it now
**Notes:** Workflow will create the project if it doesn't exist.

---

## Wrangler Configuration

| Option | Description | Selected |
|--------|-------------|----------|
| Token + Account ID only | No wrangler.toml — secrets passed directly to wrangler-action | ✓ |
| wrangler.toml with project config | Create wrangler.toml with project name, compatibility date, etc. | |

**User's choice:** Token + Account ID only (Recommended)
**Notes:** Simpler, fewer files.

---

## Build Artifact Path

| Option | Description | Selected |
|--------|-------------|----------|
| Root-level site/ | site/ at repo root — standard GitHub Actions artifact | ✓ |
| book/site/ | Build inside book/ directory | |

**User's choice:** Root-level site/ (Recommended)
**Notes:** MkDocs needs `site_dir` config adjustment for output to repo root from book/ source.

---

## Deployment Monitoring

| Option | Description | Selected |
|--------|-------------|----------|
| Fail the check, no notification | GitHub Actions job fails, red X on commit | ✓ |
| Fail the check + send email | Failure shows as red X AND sends email notification | |
| Slack notification | Post failure notification to a Slack channel | |

**User's choice:** Fail the check, no notification (Recommended)
**Notes:** No notification integrations. Failures visible as red X on the commit.

---

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