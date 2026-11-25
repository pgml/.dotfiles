#!/bin/sh
# Power modes via TLP profiles: Silent (power-saver), Office (balanced), Performance
# Usage: niri-powermode.sh              -> print current mode (for ironbar)
#        niri-powermode.sh cycle        -> switch to the next mode
#        niri-powermode.sh set <mode>   -> switch to power-saver|balanced|performance
#        niri-powermode.sh cool         -> full fan until 50°C (needs /usr/local/sbin/fan-cool)

label() {
	case $1 in
		power-saver) echo "󰤄  Silent" ;;
		balanced)    echo "󰾅  Office" ;;
		performance) echo "󰓅  Perf" ;;
		*)           echo "? $1" ;;
	esac
}

CUR=$(tlpctl get)

case $1 in
	cycle)
		case $CUR in
			power-saver) NEXT=balanced ;;
			balanced)    NEXT=performance ;;
			*)           NEXT=power-saver ;;
		esac
		;;
	set)
		NEXT=$2
		;;
	cool)
		# Silent profile + full fan until 50°C, then restore the previous mode
		notify-send "Power mode" "󰜗 Cooling down to 50°C"
		tlpctl set power-saver >/dev/null
		sudo -n /usr/local/sbin/fan-cool 50
		tlpctl set "$CUR" >/dev/null
		notify-send "Power mode" "Cooled down, back to $(label "$CUR")"
		exit
		;;
esac

if [ -n "$NEXT" ]; then
	tlpctl set "$NEXT" >/dev/null && CUR=$NEXT
	notify-send \
		--hint=string:x-canonical-private-synchronous:powermode \
		--expire-time=1000 \
		"Power mode" "$(label "$CUR")"
fi

[ -e /run/fan-cool ] && echo "󰜗  Cool" || label "$CUR"
