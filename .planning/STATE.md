# State — From Exploration to Engineering

## Project Reference

**Core Value:** Students who finish this book can confidently build and deploy AI-supported applications using modern LLM, RAG, and agentic workflow patterns — ready for internships or entry-level roles.
**Current Focus:** Phase 1: Foundation (ch1 content + local build)

## Current Position

**Milestone:** v1
**Phase:** 1 (Foundation)
**Plan:** TBD
**Status:** Not started
**Progress:** 0%

## Performance Metrics

- Requirements mapped: 17/17 (100%)
- Phases defined: 4
- Plans complete: 0/19

## Accumulated Context

### Decisions
- Tutorial format drives each chapter: concept → code → deployable artifact
- GitHub Actions + Cloudflare Pages for CI/CD (free, fast, developer-friendly)
- Python-first (dominant for AI tooling)
- Coarse granularity: 4 phases, 1-3 plans each

### Phase Dependencies
- Phase 2 (Pipeline) depends on Phase 1 (Foundation)
- Phase 3 (Polish) depends on Phase 2 (Pipeline)
- Phase 4 (Ch2) depends on Phase 3 (Polish)

### Notes
- BUILD requirements (BUILD-01, BUILD-03) belong to Phase 1 — local development is foundation
- BUILD-02 (EPUB export) belongs to Phase 3 — after deployment pipeline is verified
- SITE-01 (live URL) belongs to Phase 3 — requires Phase 2 pipeline to produce it
- CONTENT-04/05 (Ch2/3+) assigned to Phase 4 — after site is production-ready

## Session Continuity

No previous sessions recorded.