#!/usr/bin/env bash

OUTPUT_DMG=output/LlamaChat.dmg

if [ "$#" -ne 1 ]; then
    SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
    BASENAME=$(basename "$SCRIPT")

    echo "Usage: $BASENAME <source_folder>"
    echo ""
    echo "All contents of <source_folder> will be copied into the disk image."
    exit 1
fi

if ! [ -d "$1/LlamaChat.app" ]; then
    exit 1
fi

echo "Checking notarization status..."

if ! spctl -a -vvv -t install "$1/LlamaChat.app" &> /dev/null; then
    echo "Error: LlamaChat.app should be notarized before packaging into a .dmg"
    exit 1
fi

echo "Making AppIcon.icns..."
rm -rf tmp
mkdir -p tmp/AppIcon.iconset
cp ../LlamaChat/Assets.xcassets/AppIcon.appiconset/*.png tmp/AppIcon.iconset

if ! iconutil -c icns tmp/AppIcon.iconset; then
    echo "Error: couldn't make AppIcon.icns"
    exit 1
fi

if ! command -v create-dmg &> /dev/null; then
    echo "Error: missing create-dmg. Install using 'brew install create-dmg'"
    exit 1
fi

test -f "$OUTPUT_DMG" && rm "$OUTPUT_DMG"
create-dmg \
      --volname "LlamaChat" \
      --volicon "tmp/AppIcon.icns" \
      --background "../Resources/dmg-background.png" \
      --window-pos 200 120 \
      --window-size 650 440 \
      --icon-size 128 \
      --icon "LlamaChat.app" 188 198 \
      --hide-extension "LlamaChat.app" \
      --app-drop-link 460 198 \
      "LlamaChat.dmg" \
      "$1"

rm -rf tmp
