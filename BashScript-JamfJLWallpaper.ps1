#!/bin/bash

# Path to the wallpaper image
WALLPAPER="/Library/Application Support/JLTools/JLWallpaper.png"

# Get currently logged in user
CURRENT_USER=$(stat -f%Su /dev/console)

# Set the wallpaper using AppleScript for logged-in user
sudo -u "$CURRENT_USER" osascript <<EOF
tell application "System Events"
    set picture of every desktop to POSIX file "$WALLPAPER"
end tell
EOF
