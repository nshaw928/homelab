#!/bin/sh
# Create placeholder assets for the private stoatchat/assets submodule.
# These are minimal SVGs/PNGs that let the build succeed.
set -e

ASSETS="packages/client/public/assets"

mkdir -p "$ASSETS/web" "$ASSETS/badges"

# Minimal 1x1 transparent PNG (base64-decoded)
PIXEL=$(printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n\xb4\x00\x00\x00\x00IEND\xaeB`\x82')

# Placeholder SVG template
svg() {
  echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/></svg>'
}

# Web assets
echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 40"><text x="0" y="30" font-size="28" fill="white">Stoat</text></svg>' > "$ASSETS/web/wordmark.svg"
svg > "$ASSETS/web/monochrome.svg"
printf '%s' "$PIXEL" > "$ASSETS/web/android-chrome-192x192.png"
printf '%s' "$PIXEL" > "$ASSETS/web/android-chrome-512x512.png"
printf '%s' "$PIXEL" > "$ASSETS/web/masking-512x512.png"
# Empty ICO (browsers handle missing favicons gracefully)
printf '' > "$ASSETS/web/icon.ico"

# Badge SVGs
for badge in amog amorbus developer early_adopter founder moderation paw raccoon supporter translator; do
  svg > "$ASSETS/badges/$badge.svg"
done

echo "Created placeholder assets in $ASSETS"
