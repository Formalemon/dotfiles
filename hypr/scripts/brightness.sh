#!/bin/bash

change=$1

# Adjust brightness
brightnessctl set "$change"

# Wait a moment to let it apply
sleep 0.1

# Get current brightness percentage
percent=$(brightnessctl | grep -oP '\(\K[0-9]+(?=%\))')

# Choose icon based on level
if [ "$percent" -le 20 ]; then
  icon="🌑"
elif [ "$percent" -le 40 ]; then
  icon="🌘"
elif [ "$percent" -le 60 ]; then
  icon="🌗"
elif [ "$percent" -le 80 ]; then
  icon="🌖"
else
  icon="🌕"
fi

# Send notification
notify-send -t 1000 "$icon Brightness: $percent%"


