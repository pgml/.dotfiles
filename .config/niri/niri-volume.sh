#!/bin/sh

SINK="$1"

if [[ $1 -eq "default" ]]; then
	SINK="@DEFAULT@"
fi

sound_file=/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga

echo $SINK

get_volume() {
	pactl get-sink-volume "$SINK" | awk '/Volume:/ {
		for (i = 1; i <= NF; i++) {
			if ($i ~ /%/) {
				gsub(/%/, "", $i)
				print $i
				exit
			}
		}
	}'
}

case $2 in
	up)
		pactl set-sink-volume "$SINK" +5%
		paplay --d="$SINK" $sound_file
		volume=$(get_volume "$SINK")
		notify-send \
			--hint=string:x-canonical-private-synchronous:volume \
			--expire-time=500 \
			"Volume ${SINK}" "${volume}%"
		;;
	down)
		pactl set-sink-volume "$SINK" -5%
		paplay --d="$SINK" $sound_file
		volume=$(get_volume "$SINK")
		notify-send --hint=string:x-canonical-private-synchronous:volume \
			--expire-time=500 \
			"Volume ${SINK}" "${volume}%";
		;;
	*)
		echo "Usage: $0 default|jack_out|jack_out.3 up|down"
		exit 1
		;;
esac
