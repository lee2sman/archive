#!/bin/bash

# Set folders
INPUT_DIR="items"
OUTPUT_DIR="docs"
TEMPLATE_DIR="templates"
TEMPLATE="$TEMPLATE_DIR/item.html"
ASSETS_SRC_DIR="assets"
ASSETS_DEST_DIR="$OUTPUT_DIR/assets"
HEADER_FILE="$TEMPLATE_DIR/header.html"
FOOTER_FILE="$TEMPLATE_DIR/footer.html"

# Clean output directory before building
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy assets (css, img, font, etc.) into output directory
cp -r "$ASSETS_SRC_DIR" "$ASSETS_DEST_DIR"

# Start landing page by inserting header file
cat "$HEADER_FILE" > "$OUTPUT_DIR/index.html"

# Init tracking arrays
skipped_files=()
skipped_errors=()
processed_files=()

# Process any pages in root directory
echo "⛏️ Building root pages"
for file in *.md; do
  base=$(basename "$file" .md)
  subdir="$OUTPUT_DIR/$base"
  html_file="$subdir/index.html"

  mkdir -p "$subdir"

  # Run pandoc
  pandoc "$file" --template="$TEMPLATE" -o "$html_file" --quiet
done

# Process each item's markdown file
echo "📜 Building archive item pages"
for file in "$INPUT_DIR"/*.md; do
  base=$(basename "$file" .md)
  subdir="$OUTPUT_DIR/$base"
  html_file="$subdir/index.html"

  mkdir -p "$subdir"

  # Run pandoc to generate HTML, capture stderr
  html_err=$(pandoc "$file" --template="$TEMPLATE" -o "$html_file" 2>&1 >/dev/null)
  if echo "$html_err" | grep -Eiq "yaml.*(error|exception|parse)"; then
    skipped_files+=("$file")
    skipped_errors+=("$html_err")
    continue
  fi

  # Run pandoc to extract metadata, capture stderr
  meta_output=$(pandoc "$file" --lua-filter="$TEMPLATE_DIR/extract-meta.lua" 2>&1)
  if echo "$meta_output" | grep -Eiq "yaml.*(error|exception|parse)"; then
    skipped_files+=("$file")
    skipped_errors+=("$meta_output")
    continue
  fi

  # Assume stdout was JSON metadata
  metadata_json="$meta_output"

  # Lenient field parsing with fallbacks
  title=$(echo "$metadata_json" | jq -r '.title' 2>/dev/null)
  [ -z "$title" ] || [ "$title" = "null" ] && title="Untitled"

  description=$(echo "$metadata_json" | jq -r '.description' 2>/dev/null)
  [ -z "$description" ] || [ "$description" = "null" ] && description=""

  alt=$(echo "$metadata_json" | jq -r '.alt' 2>/dev/null)
  [ -z "$alt" ] || [ "$alt" = "null" ] && alt=""

  image=$(echo "$metadata_json" | jq -r '.image' 2>/dev/null)
  [ -z "$image" ] || [ "$image" = "null" ] && image="default.png"

  editor_note=$(echo "$metadata_json" | jq -r '.editor_note' 2>/dev/null)
  [ -z "$editor_note" ] || [ "$editor_note" = "null" ] && editor_note=""

  # Append entry to landing page
  cat <<EOF >> "$OUTPUT_DIR/index.html"
  <a href="$base">
    <div>
      <img src="assets/img/$image" alt="$alt" loading="lazy">
      <h2>$title</h2>
      <p>$description</p>
    </div>
  </a>
EOF

  processed_files+=("$file")
done

# Finish landing page by inserting footer file
cat "$FOOTER_FILE" >> "$OUTPUT_DIR/index.html"

# Summary report
echo ""
if [ "${#skipped_files[@]}" -gt 0 ]; then
  echo "❌ Skipped ${#skipped_files[@]} file(s) due to YAML parsing errors:"
  for i in "${!skipped_files[@]}"; do
    echo "  - ${skipped_files[$i]}"
    echo "    Error:"
    echo "${skipped_errors[$i]}" | sed 's/^/      /'
    echo ""
  done
fi

if [ "${#processed_files[@]}" -gt 0 ]; then
  echo "✅ Successfully processed ${#processed_files[@]} file(s)."
else
  echo "⚠️ No files were successfully processed."
fi

echo ""
