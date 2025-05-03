#!/bin/bash

# Script to float, resize, and center the Firefox Google Sign-in window
# based on its title, reacting to title changes after creation.

# --- Configuration ---
TARGET_TITLE="Sign in – Google accounts — Mozilla Firefox"
WIDTH=960
HEIGHT=540
POS_X=480
POS_Y=270
# --- End Configuration ---

# Function to apply transformations
apply_rules() {
  local address=$1
  echo "Applying rules to window address: $address"
  hyprctl --batch "\
  dispatch setfloating address:0x${address};\
  dispatch resizewindowpixel exact $WIDTH $HEIGHT, address:0x${address};\
  dispatch movewindowpixel exact $POS_X $POS_Y, address:0x${address}" >> /tmp/hypr_google_signin_script.log 2>&1
}

echo "Starting Google Sign-in window handler script..." > /tmp/hypr_google_signin_script.log

# Listen to Hyprland events via socket
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r event; do
  # Check if it's a window title change event
  # Format: windowtitle>>windowaddress
  if [[ "$event" == windowtitlev2* ]]; then
    payload=${event#windowtitlev2>>}
    window_address=${payload%%,*}
    window_title=${payload#*,}
    echo "Current window title: $window_title"
  
    # Check if the new title matches the target
    if [[ "$window_title" == "$TARGET_TITLE" ]]; then
      echo "Target title matched for $window_address. Applying rules." >> /tmp/hypr_google_signin_script.log
      apply_rules "$window_address"
    fi
  fi
done
