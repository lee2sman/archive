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
RSS_FILE="$OUTPUT_DIR/feed.xml"

# RSS configuration
SITE_TITLE="➘Dig Archive"
SITE_URL="https://leetusman.com/archive"
SITE_DESCRIPTION="An archived collection of digitized media art, text, zines, videos, and other saved works from around the net, and beyond."
RSS_MAX_ITEMS=10

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Copy assets (css, img, font, etc.) into output directory
cp -r "$ASSETS_SRC_DIR" "$ASSETS_DEST_DIR"

# Start landing page by inserting header file
cat "$HEADER_FILE" > "$OUTPUT_DIR/index.html"

# Init tracking arrays
skipped_files=()
skipped_errors=()
processed_files=()
new_items_rss=()

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

  # Check if subdirectory already exists and skip processing if it does
  if [ -d "$subdir" ] && [ -f "$html_file" ]; then
    echo "⚡ Skipping $base (already exists)"
    
    # Still need to extract metadata for the landing page
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
    continue
  fi

  # Run pandoc to generate HTML, capture stderr
  echo "🔨 Building $base"
  html_err=$(pandoc "$file" --template="$TEMPLATE" -o "$html_file" --variable="item_path:$base" 2>&1 >/dev/null)
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

  # Add to RSS items array (only for newly built items)
  new_items_rss+=("$base|$title|$description")

  processed_files+=("$file")
done

# Finish landing page by inserting footer file
cat "$FOOTER_FILE" >> "$OUTPUT_DIR/index.html"

# Generate RSS feed
echo "📡 Generating RSS feed"
current_date=$(date -u "+%a, %d %b %Y %H:%M:%S GMT")

cat <<EOF > "$RSS_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>$SITE_TITLE</title>
    <link>$SITE_URL</link>
    <description>$SITE_DESCRIPTION</description>
    <lastBuildDate>$current_date</lastBuildDate>
    <generator>Custom Static Site Generator</generator>
EOF

# Add RSS items (limit to RSS_MAX_ITEMS, newest first)
items_to_process=${#new_items_rss[@]}
if [ $items_to_process -gt $RSS_MAX_ITEMS ]; then
  items_to_process=$RSS_MAX_ITEMS
fi

for ((i=$items_to_process-1; i>=0; i--)); do
  IFS='|' read -r item_base item_title item_description <<< "${new_items_rss[$i]}"
  
  # XML escape function for basic entities
  item_title_escaped=$(echo "$item_title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  item_description_escaped=$(echo "$item_description" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  
  cat <<EOF >> "$RSS_FILE"
    <item>
      <title>$item_title_escaped</title>
      <link>$SITE_URL/$item_base</link>
      <description>$item_description_escaped</description>
      <guid>$SITE_URL/$item_base</guid>
      <pubDate>$current_date</pubDate>
    </item>
EOF
done

cat <<EOF >> "$RSS_FILE"
  </channel>
</rss>
EOF

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
  if [ "${#new_items_rss[@]}" -gt 0 ]; then
    echo "📡 RSS feed generated with ${#new_items_rss[@]} new item(s)."
  else
    echo "📡 RSS feed generated (no new items)."
  fi
else
  echo "⚠️ No files were successfully processed."
fi

echo ""
