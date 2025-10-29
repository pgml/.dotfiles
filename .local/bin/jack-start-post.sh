#!/bin/bash
pactl load-module module-jack-sink client_name=Desktop channels=2 connect=no
pactl load-module module-jack-sink client_name=Discord channels=2 connect=no
pactl load-module module-jack-sink client_name=BGM channels=2 connect=no
pactl load-module module-jack-sink client_name=Game channels=2 connect=no
# pactl load-module module-jack-source client_name=Desktop_In channels=2 connect=no
# pactl load-module module-jack-source client_name=Discord_In channels=2 connect=no
# pactl load-module module-jack-source client_name=BGM_In channels=2 connect=no
# pactl load-module module-jack-source client_name=Game_In channels=2 connect=no
pactl load-module module-jack-source client_name=Broadcast channels=2

pacmd set-default-sink jack_out
pacmd set-default-source jack_in

# Since Jack2 has no own MIDI support, so we need this bridge
# a2jmidid -e &
