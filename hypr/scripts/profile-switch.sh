#!/bin/bash

gdbus monitor \
  --system \
  --dest net.hadess.PowerProfiles \
  --object-path /net/hadess/PowerProfiles \
| while read -r line; do
    if [[ "$line" == *"ActiveProfile"* ]]; then
        profile=$(asusctl profile -p | grep -oP "Active profile is \K.*")
	case "$profile" in
  	    Performance) icon="🚀" ;;
  	    Balanced)    icon="🌗" ;;
  	    Quiet)       icon="🌙" ;;
  	    *)           icon="󰾆" ;;
	esac
	notify-send "$icon Profile: $profile"
    fi
done

