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

# Process each markdown file
for file in "$INPUT_DIR"/*.md; do
  echo "Processing $file"
  base=$(basename "$file" .md)
  subdir="$OUTPUT_DIR/$base"
  html_file="$subdir/index.html"

  # Make subdirectory for this item
  mkdir -p "$subdir"

  # Generate individual HTML using provided template
  pandoc "$file" --template="$TEMPLATE" -o "$html_file"

  # Extract metadata
  metadata_json=$(pandoc $file --lua-filter=$TEMPLATE_DIR/extract-meta.lua)

  # Parse fields with jq
  title=$(echo "$metadata_json" | jq -r '.title')
  description=$(echo "$metadata_json" | jq -r '.description')
  alt=$(echo "$metadata_json" | jq -r '.alt')
  image=$(echo "$metadata_json" | jq -r '.image')

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

done

# Finish landing page by inserting footer file
cat "$FOOTER_FILE" >> "$OUTPUT_DIR/index.html"

echo "Site generated in $OUTPUT_DIR/"
