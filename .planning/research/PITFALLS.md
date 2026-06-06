# Domain Pitfalls: MkDocs Technical Book + GitHub Actions + Cloudflare Pages

**Domain:** Technical book publishing with MkDocs + Material theme, deployed via GitHub Actions to Cloudflare Pages
**Researched:** 2026-06-06
**Confidence:** MEDIUM-HIGH (official docs confirmed; some ecosystem patterns verified via mkdocs-material documentation)

---

## Critical Pitfalls

### Pitfall 1: Missing `search` Plugin After Explicit Plugin Definition

**What goes wrong:** Search stops working. Users cannot find content on the site.

**Why it happens:** When you add any plugin to `mkdocs.yml`, the default plugins (including `search`) are no longer automatically included. The search plugin must be explicitly listed.

**Prevention:**
```yaml
plugins:
  - search       # Must include explicitly
  - mkdocs-material-navigation-headers  # or other plugins
```

**Phase:** BOOK-03 (CI/CD pipeline setup) - configure `mkdocs.yml` plugins before building the workflow.

**Detection:** Search returns no results or blank search modal.

---

### Pitfall 2: Wrong Build Command for MkDocs in Cloudflare Pages

**What goes wrong:** Build fails with non-zero exit code. Deployment never completes.

**Why it happens:** Cloudflare Pages defaults expect framework-specific commands like `npm run build`. MkDocs uses `mkdocs build` and outputs to `site/` (not `dist/`).

**Prevention:** When setting up Cloudflare Pages via dashboard or `wrangler pages deploy`, use:
- **Build command:** `mkdocs build`
- **Build directory:** `site`

**Phase:** BOOK-03 (CI/CD pipeline) - verify build command and output directory in Cloudflare Pages project settings.

**Detection:** Build logs show "command not found" or "build directory empty."

---

### Pitfall 3: Wrangler Requires Node.js 16.17.0+

**What goes wrong:** `wrangler pages deploy` fails in GitHub Actions with version compatibility errors.

**Why it happens:** Older GitHub Actions runners or cached Node.js versions ship with Node.js < 16.17.0, which Wrangler v3 requires.

**Prevention:** In your workflow file:
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'  # Pin to a recent stable version
```

**Phase:** BOOK-03 - set explicit Node.js version in GitHub Actions workflow before running Wrangler.

**Detection:** Error message contains "Wrangler requires Node.js 16.17.0 or higher."

---

### Pitfall 4: Missing Cloudflare API Token Permissions

**What goes wrong:** Deployment fails with authentication error. Wrangler cannot deploy to Cloudflare Pages.

**Why it happens:** API token does not have the correct scope. Cloudflare Pages deployments require **Account > Cloudflare Pages > Edit** permissions, not just Zone-level permissions.

**Prevention:**
1. Go to Cloudflare Dashboard > My Profile > API Tokens
2. Create custom token with template "Cloudflare Pages" or manually set:
   - **Account > Cloudflare Pages > Edit**
3. Store `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as GitHub Secrets
4. Reference in workflow:
```yaml
with:
  apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
  accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

**Phase:** BOOK-03 - configure secrets before first deployment.

**Detection:** Error: "Cloudflare API token is invalid" or "Permission denied."

---

### Pitfall 5: Build Image Version Upgrades Breaking Builds

**What goes wrong:** Builds pass locally but fail on Cloudflare Pages after a automatic build image update.

**Why it happens:** Cloudflare Pages build image (v3) auto-updates. Changes include Python 3.13.3 default (as of research date), Node.js 22.16.0 default. Features like `pipenv` or Yarn lock detection are not supported in v3.

**Prevention:**
1. Pin Python and Node.js versions in your project root:
   - Create `.python-version` file with exact version (e.g., `3.12`)
   - Create `.nvmrc` file with exact version (e.g., `20`)
2. Set environment variables in Cloudflare Pages project settings:
   - `PYTHON_VERSION=3.12`
   - `NODE_VERSION=20`

**Phase:** BOOK-03 - pin versions before deploying to avoid silent breakage on future image updates.

**Detection:** Build fails after Cloudflare announces build image update. Check [Cloudflare announcements](https://developers.cloudflare.com/pages/configuration/build-image/) for changes.

---

### Pitfall 6: Draft Files Not Working with `exclude_docs`

**What goes wrong:** Draft chapters appear in production build. Students see unfinished content.

**Why it happens:** The `exclude_docs` option no longer handles drafts in `mkdocs serve`. The newer `draft_docs` option is required.

**Prevention:**
```yaml
# mkdocs.yml
draft_docs:
  - draft-chapter-name
  # OR use glob patterns:
  - "ch*/draft-*.md"
```

**Phase:** BOOK-02 (Ch1 polish) or BOOK-05 (Ch2) - configure draft handling early to avoid publishing drafts.

**Detection:** Draft content appears on deployed site.

---

### Pitfall 7: Edit Links Require Login on GitHub

**What goes wrong:** "Edit this page" links on MkDocs material theme redirect to GitHub login instead of the raw file.

**Why it happens:** Default edit URI template uses `edit/master/docs/` which requires authentication on private repos or results in404 for read-only access.

**Prevention:** Use the blob path for anonymous read-only access:
```yaml
edit_uri: blob/main/docs/
# If using master branch:
edit_uri: blob/master/docs/
```

**Phase:** BOOK-02 or BOOK-03 - set correct `edit_uri` before deploying.

**Detection:** Users cannot edit page links without logging in.

---

## Moderate Pitfalls

### Pitfall 8: Build Cache Not Purging on Persistent Failures

**What goes wrong:** Build continues to fail even after fixing the underlying issue. Stale cached dependencies conflict with new configuration.

**Why it happens:** Cloudflare Pages build cache expires after 7 days of inactivity but persists during active development. If corrupted dependencies are cached, they remain until manually cleared.

**Prevention:** During active development, clear cache via dashboard (Settings > Build > Build cache > Clear cache) when debugging build failures.

**Phase:** BOOK-03 - during initial CI/CD setup and whenever build behaves unexpectedly.

**Detection:** Build fails with error that does not match local build output.

---

### Pitfall 9: Subdirectory Hosting Without Updating `site_url`

**What goes wrong:** Site loads but CSS/JS assets return 404. Navigation links point to wrong URLs.

**Why it happens:** When hosting at a subdirectory (e.g., `https://book.example.com/chapter1/`), relative asset paths break without proper `site_url` configuration.

**Prevention:**
```yaml
site_url: https://book.example.com/ # Include trailing slash
```

**Phase:** BOOK-04 - when first deploying to a non-root domain or subdirectory.

**Detection:** Missing stylesheets/scripts in browser dev tools. Links work but assets fail to load.

---

### Pitfall 10: Triggering on Every Push Without Branch Filters

**What goes wrong:** Every commit to every branch triggers a deployment. GitHub Actions minutes burn rapidly. Multiple preview deployments accumulate.

**Why it happens:** Default workflow trigger is `on: [push]` without branch restrictions.

**Prevention:**
```yaml
on:
  push:
    branches:
      - main  # Only deploy from main branch
  pull_request:
    branches:
      - main  # Optional: preview deployments for PRs
```

**Phase:** BOOK-03 - configure branch filters in workflow before enabling the repository.

**Detection:** GitHub Actions shows many deployments for branches that should not deploy.

---

### Pitfall 11: Missing Output Directory in Wrangler Command

**What goes wrong:** Wrangler deploys empty directory. Site loads with no content.

**Why it happens:** The `pages deploy` command requires explicit output directory. The `site/` directory is not automatically used.

**Prevention:**
```yaml
command: pages deploy site --project-name=YOUR_PROJECT_NAME
```

**Phase:** BOOK-03 - verify deploy command matches MkDocs output directory.

**Detection:** Deployed site shows "Welcome to MkDocs" or blank page instead of book content.

---

## Minor Pitfalls

### Pitfall 12: Build Skipping Flag Misconfiguration

**What goes wrong:** Intended builds are skipped when adding "[CI skip]" for unrelated changes.

**Why it happens:** Cloudflare Pages ignores `[CI skip]` but respects `[CF-Pages-Skip]` in commit messages.

**Prevention:** Use `[CF-Pages-Skip]` instead of `[CI skip]` to selectively skip Cloudflare Pages deployments:
```bash
git commit -m "chore: update notes [CF-Pages-Skip]"
```

**Phase:** BOOK-03 - document for contributors if working with multiple collaborators.

---

### Pitfall 13: Wrong YAML Indentation for Plugin/Extension Options

**What goes wrong:** MkDocs fails to start or plugins do not load. Errors point to `mkdocs.yml` parsing issues.

**Why it happens:** YAML requires colon after extension name, then options indented on new lines. Common mistake is inline syntax or wrong indentation.

**Prevention:**
```yaml
markdown_extensions:
  - pymdownx.highlight:
      anchor_linenums: true
  - toc:
      permalink: true
```

**Phase:** BOOK-02/BOOK-03 - use a YAML validator (e.g., `yamllint`) in CI to catch syntax errors early.

**Detection:** `mkdocs serve` exits immediately or `mkdocs build` fails with YAML parsing error.

---

## Phase-Specific Warnings

| Phase | Topic | Likely Pitfall | Mitigation |
|-------|-------|----------------|------------|
| BOOK-02 | Ch1 polish | Draft files appearing in production | Configure `draft_docs` before first deploy |
| BOOK-03 | CI/CD pipeline | Wrong build command/directory | Use `mkdocs build` and `site` directory |
| BOOK-03 | CI/CD pipeline | Missing Cloudflare secrets | Set `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` |
| BOOK-03 | CI/CD pipeline | Node.js version mismatch | Pin Node.js version in workflow |
| BOOK-04 | Live deployment | Build cache corruption | Clear cache if build behaves unexpectedly |
| BOOK-04 | Live deployment | Version upgrades breaking builds | Pin Python/Node.js with `.python-version` and `.nvmrc` |

---

## Sources

- [MkDocs Configuration - Common Issues](https://www.mkdocs.org/user-guide/configuration/) (HIGH confidence - official docs)
- [Cloudflare Pages - Deploy with Direct Upload + CI/CD](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration/) (HIGH confidence - official docs)
- [Cloudflare Pages - Build Configuration](https://developers.cloudflare.com/pages/configuration/build-configuration/) (HIGH confidence - official docs)
- [Cloudflare Pages - Build Caching](https://developers.cloudflare.com/pages/configuration/build-caching/) (HIGH confidence - official docs)
- [Cloudflare Pages - GitHub Integration](https://developers.cloudflare.com/pages/configuration/git-integration/github-integration/) (HIGH confidence - official docs)
- [Cloudflare Pages - Build Image](https://developers.cloudflare.com/pages/configuration/build-image/) (HIGH confidence - official docs)
- [mkdocs-material GitHub Actions workflow](https://github.com/squidfunk/mkdocs-material/blob/master/.github/workflows/build.yml) (MEDIUM confidence - reference workflow)