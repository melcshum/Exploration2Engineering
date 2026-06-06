# Technology Stack

**Project:** From Exploration to Engineering (Technical Book)
**Researched:** 2026-06-06
**Confidence:** HIGH

## Recommended Stack

### Core Documentation Framework

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **MkDocs** | 1.6.x | Static site generator | Proven, well-documented, Python-native; built-in `gh-deploy`; [official docs](https://www.mkdocs.org) confirm 1.6.x is current stable |
| **Material for MkDocs** | 9.7.x | Theme | Best-in-class documentation theme; search, navigation, code highlighting all built-in; [Context7 verified](https://github.com/squidfunk/mkdocs-material) |
| **Python** | 3.12 | Runtime | Latest stable Python; MkDocs requires 3.8+; Cloudflare Pages supports 3.11+ |

### CI/CD and Deployment

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **GitHub Actions** | — | CI/CD pipeline | Native to repo; free for open source; [Context7 verified](https://github.com/mkdocs/mkdocs/wiki/Mkdocs-Deployments) |
| **cloudflare/wrangler-action** | v3 | Deployment | [Official Cloudflare docs](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) recommend this over pages-action for flexibility |
| **actions/checkout** | v6 | Repository checkout | Latest major version; required for wrangler-action |

### Supporting Tools

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **pip-tools** | latest | Dependency locking | Generate reproducible `requirements.txt` |
| **mkdocs-material-extensions** | latest | Enhanced code features | If needing additional code annotation features beyond built-in |

## Project-Specific Configuration

Based on the existing `book/mkdocs.yml` and `book/docs/` structure:

```yaml
# book/mkdocs.yml (current config is sound)
site_name: From Exploration to Engineering
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.instant
    - content.code.copy
    - search.suggest
plugins:
  - search
```

## GitHub Actions Workflow

**Recommended approach:** Use `cloudflare/wrangler-action@v3` as shown in official Cloudflare docs.

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloudflare Pages

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write

    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          pip install -r book/requirements.txt

      - name: Build MkDocs
        run: mkdocs build -f book/mkdocs.yml

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy book/site --project-name=exploration-to-engineering
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

## Requirements File

```text
# book/requirements.txt
mkdocs>=1.6.0
mkdocs-material>=9.7.0
mkdocs-mermaid2-plugin>=0.6.0
```

## What NOT to Use and Why

| Technology | Why Avoid | Instead Use |
|------------|-----------|-------------|
| **Sphinx** | Steeper learning curve; more complex theming | MkDocs (simpler, Markdown-first) |
| **cloudflare/pages-action@v1** | Deprecated in favor of wrangler-action | `cloudflare/wrangler-action@v3` |
| **Python 3.7** | MkDocs 1.6+ requires 3.8+; Cloudflare Pages dropped support | Python 3.12 |
| **actions/checkout@v3/v4** | v6 has better performance and security | actions/checkout@v6 |
| **MkDocs Insiders (paid)** | Unnecessary unless requiring premium features | Open-source Material for MkDocs |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Documentation | MkDocs + Material | Sphinx + RTD theme | Sphinx has steeper learning curve; MkDocs is simpler for Markdown-heavy content |
| Deployment | Cloudflare Pages | GitHub Pages | Cloudflare has better global edge network; more generous free tier for static sites |
| CI/CD | GitHub Actions | Netlify CI | GitHub Actions is native to the repository; no additional service needed |

## Installation

```bash
# Local development
pip install -r book/requirements.txt
mkdocs serve -f book/mkdocs.yml

# Production build
mkdocs build -f book/mkdocs.yml
```

## Sources

- [MkDocs Installation & Deployment](https://github.com/mkdocs/mkdocs/wiki/Mkdocs-Deployments) — Context7 verified
- [Material for MkDocs 9.x](https://github.com/squidfunk/mkdocs-material) — Context7 verified
- [Cloudflare Pages GitHub Actions](https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration) — Official docs
- [Cloudflare Pages Action](https://github.com/cloudflare/pages-action) — GitHub repo