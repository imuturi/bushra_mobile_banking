#!/bin/bash
PLUGINS=(
    #"image_gallery_saver-2.0.3"
    "scan-1.6.0"
)

for plugin in "${PLUGINS[@]}"; do
    PLUGIN_PATH="/Users/basam/.pub-cache/hosted/pub.dev/$plugin/android/build.gradle"
    if [ -f "$PLUGIN_PATH" ]; then
        echo "Fixing $plugin..."
        # Backup original file
        cp "$PLUGIN_PATH" "$PLUGIN_PATH.backup"
        
        # Add namespace to android block
        sed -i '' '/android {/a\
    namespace "com.example.'${plugin%%-*}'"' "$PLUGIN_PATH"
    fi
done
