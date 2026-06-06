#!/bin/bash
set -e
BOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_DIR="$BOOK_DIR/docs"
OUTPUT_DIR="$BOOK_DIR/output"
EPUB="$OUTPUT_DIR/exploration-to-engineering.epub"
mkdir -p "$OUTPUT_DIR"
pandoc \
  "$DOCS_DIR/index.md" \
  "$DOCS_DIR/ch1-ai-supported-software.md" \
  "$DOCS_DIR/ch2-agentic-workflows.md" \
  "$DOCS_DIR/ch3-model-integration.md" \
  "$DOCS_DIR/ch4-ai-driven-development.md" \
  "$DOCS_DIR/ch5-production-guardrails.md" \
  "$DOCS_DIR/ch6-conclusion.md" \
  -o "$EPUB" \
  --from markdown --to epub3 \
  --css="assets/epub.css" \
  --metadata title="From Exploration to Engineering" \
  --metadata author="Your Name"
echo "EPUB built: $EPUB"
