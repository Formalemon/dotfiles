#!/bin/bash

# Script to float, resize, and center the Firefox Google Sign-in window
# based on its title, reacting to title changes after creation.

# --- Configuration ---
TARGET_TITLE="Sign in – Google accounts — Mozilla Firefox"
TARGET_CLASS="firefox" # Optional: Add class check for safety, adjust if needed
WIDTH=960
HEIGHT=540
POS_X=480
POS_Y=270
# --- End Configuration ---

# Function to query window details using hyprctl and jq
get_window_details() {
  local address=$1
  # hyprctl clients -j outputs a JSON array of all clients
  # jq filters this array to find the object with the matching address
  hyprctl clients -j | jq --arg addr "$address" '.[] | select(.address == $addr)'
}

# Function to apply transformations
apply_rules() {
  local address=$1
  echo "Applying rules to window address: $address"
  hyprctl --batch "\
  dispatch setfloating address:${address};\
  dispatch resizewindowpixel exact $WIDTH $HEIGHT, address:${address};\
  dispatch movewindowpixel exact $POS_X $POS_Y, address:${address}" >> /tmp/hypr_google_signin_script.log 2>&1
}

echo "Starting Google Sign-in window handler script..." > /tmp/hypr_google_signin_script.log

# Listen to Hyprland events via socket
socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r event; do
  # Check if it's a window title change event
  # Format: windowtitle>>windowaddress
  if [[ $event == "windowtitle>>"* ]]; then
    window_address=$(echo "$event" | cut -d '>' -f 3) # Extracts the address part

    # Query the details of the window whose title just changed
    details=$(get_window_details "$window_address")

    # Extract the new title and class from the JSON details
    current_title=$(echo "$details" | jq -r '.title')
    current_class=$(echo "$details" | jq -r '.class') # Optional check

    echo "Title changed for address $window_address. New title: '$current_title', Class: '$current_class'" >> /tmp/hypr_google_signin_script.log

    # Check if the new title matches the target
    # Optional: Add '&& [[ "$current_class" == "$TARGET_CLASS" ]]' for extra safety
    if [[ "$current_title" == "$TARGET_TITLE" ]]; then
      echo "Target title matched for $window_address. Applying rules." >> /tmp/hypr_google_signin_script.log
      apply_rules "$window_address"
    fi
  fi
done
