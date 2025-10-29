#!/bin/sh

setvcp() {
	ddccontrol -r 0x10 -w "$2" dev:/dev/"$1" &
}

# Load current brightness (or default to 50)
CUR=50
FILE="/tmp/curbrght-${1}"
echo $FILE;
if [ -f $FILE ]; then
	CUR=$(head -n1 $FILE)
fi

case $2 in
	up)
		[ "$CUR" -lt 90 ] && CUR=$((CUR+10)) || CUR=100

		notify-send \
			--hint=string:x-canonical-private-synchronous:volume \
			--expire-time=500 \
			"Brightness ${1}" "${CUR}%"
		;;
	down)
		[ "$CUR" -gt 10 ] && CUR=$((CUR-10)) || CUR=0
		notify-send \
			--hint=string:x-canonical-private-synchronous:volume \
			--expire-time=500 \
			"Brigthness ${1}" "${CUR}%"
		;;
	*)
		echo "Usage: $0 up|down"
		exit 1
		;;
esac

echo "$CUR" > $FILE
setvcp $1 "$CUR"
