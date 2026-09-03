#!/bin/sh

set -eu

mode=${1:-}
runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
niri_socket=${NIRI_SOCKET:-}
session_name=${niri_socket##*/}
session_name=${session_name:-default}

case "$session_name" in
	*[!A-Za-z0-9._-]*) session_name=default ;;
esac

state_dir="$runtime_dir/niri-swaylock"
initialized_file="$state_dir/$session_name.initialized"
suppress_file="$state_dir/$session_name.suppress-lid-close"
launch_guard="$state_dir/$session_name.swaylock-running"

mkdir -p "$state_dir"
chmod 700 "$state_dir"

lid_is_closed() {
	for lid_state in /proc/acpi/button/lid/*/state; do
		[ -r "$lid_state" ] || continue
		grep -q '^state:[[:space:]]*closed' "$lid_state" && return 0
	done
	return 1
}

external_monitor_is_connected() {
	for connector_state in /sys/class/drm/card*-*/status; do
		[ -r "$connector_state" ] || continue
		connector_name=${connector_state%/status}
		connector_name=${connector_name##*/}

		case "$connector_name" in
			*-eDP-*|*-LVDS-*|*-DSI-*) continue ;;
		esac

		[ "$(sed -n '1p' "$connector_state")" = connected ] && return 0
	done
	return 1
}

initialize_lid_state() {
	[ -e "$initialized_file" ] && return 0

	if lid_is_closed && external_monitor_is_connected; then
		: > "$suppress_file"
	fi
	: > "$initialized_file"
}

case "$mode" in
	init)
		initialize_lid_state
		exit 0
		;;
	lid-open)
		: > "$initialized_file"
		rm -f "$suppress_file"
		exit 0
		;;
	lid-close)
		initialize_lid_state
		[ -e "$suppress_file" ] && exit 0
		;;
	explicit)
		;;
	*)
		printf 'usage: %s {init|lid-open|lid-close|explicit}\n' "$0" >&2
		exit 2
		;;
esac

# Two lid devices can report the same close event. Keep only one locker.
mkdir "$launch_guard" 2>/dev/null || exit 0
trap 'rmdir "$launch_guard" 2>/dev/null || true' EXIT HUP INT TERM

if pgrep -u "$(id -u)" -x swaylock >/dev/null 2>&1; then
	exit 0
fi

swaylock
