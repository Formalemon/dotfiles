#!/bin/bash

# Switch to next profile
asusctl profile -n
sleep 0.3

# Get current profile
profile=$(asusctl profile -p | grep -oP "Active profile is \K.*")

# Choose icon
case "$profile" in
  Performance) icon="🚀" ;;
  Balanced)    icon="🌗" ;;
  Quiet)       icon="🌙" ;;
  *)           icon="󰾆" ;;
esac

notify-send "$icon Profile: $profile"

