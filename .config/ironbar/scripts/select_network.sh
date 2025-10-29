#!/bin/bash

# Get list of SSIDs, remove duplicates and empty lines
SSID=$(nmcli -t -f SSID dev wifi | sort -u | grep -v '^$' | wofi --dmenu --prompt "Select Network")

[ -z "$SSID" ] && exit 0

# Ask for password
PASS=$(wofi --dmenu --password --prompt "Enter password for $SSID")

[ -z "$PASS" ] && exit 0

# Attempt to connect
nmcli dev wifi connect "$SSID" password "$PASS"
