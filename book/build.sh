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
  "$DOCS_DIR/ch2-plan-and-execute.md" \
  "$DOCS_DIR/ch3-model-integration.md" \
  "$DOCS_DIR/ch4-ai-driven-development.md" \
  -o "$EPUB" \
  --from markdown --to epub3 \
  --split-level=1 \
  --toc --toc-depth=2 \
  --css="$BOOK_DIR/docs/assets/epub.css" \
  --metadata title="From Exploration to Engineering" \
  --metadata author="Your Name" \
  --metadata lang="en"
echo "EPUB built: $EPUB"
