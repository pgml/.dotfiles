#!/bin/bash

STATE_FILE="/tmp/ironbar_hidden"

if [ -f "$STATE_FILE" ]; then
	kquitapp6 kded6
	ironbar & disown
	sleep 0.1  # give Ironbar time to map
	#niri-msg set workspace-margin top 30
	rm "$STATE_FILE"
else
	pkill -x ironbar
	#niri-msg set workspace-margin top 0
	touch "$STATE_FILE"
fi
