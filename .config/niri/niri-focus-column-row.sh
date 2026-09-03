#!/usr/bin/env bash

set -euo pipefail

direction="${1:-}"
state="${XDG_RUNTIME_DIR:-/tmp}/niri-preferred-row.json"

case "$direction" in
    left|right) ;;
    *) exit 2 ;;
esac

if [[ "$(niri msg -j overview-state | jq -r '.is_open')" == "true" ]]; then
    rm -f "$state"
    niri msg action "focus-column-$direction"
    exit 0
fi

windows="$(niri msg -j windows)"

focused="$(
    jq -c 'first(.[] | select(.is_focused))' <<< "$windows"
)"

[[ "$focused" != "null" && -n "$focused" ]] || exit 0

id="$(jq -r '.id // empty' <<< "$focused")"
workspace="$(jq -r '.workspace_id // empty' <<< "$focused")"
column="$(jq -r '.layout.pos_in_scrolling_layout[0] // empty' <<< "$focused")"
row="$(jq -r '.layout.pos_in_scrolling_layout[1] // empty' <<< "$focused")"

[[ -n "$id" && -n "$workspace" && -n "$column" && -n "$row" ]] || exit 0

desired_row="$row"
using_remembered_row=false

if [[ -f "$state" ]]; then
    saved_workspace="$(jq -r '.workspace_id // empty' "$state")"
    saved_anchor="$(jq -r '.anchor_id // empty' "$state")"
    saved_row="$(jq -r '.row // empty' "$state")"

    if [[ "$saved_workspace" == "$workspace" &&
          "$saved_anchor" == "$id" &&
          -n "$saved_row" ]]; then
        desired_row="$saved_row"
        using_remembered_row=true
    else
        rm -f "$state"
    fi
fi

if [[ "$direction" == "left" ]]; then
    target_column=$((column - 1))
else
    target_column=$((column + 1))
fi

(( target_column >= 1 )) || exit 0

source_windows="$(
    jq -c \
        --argjson workspace "$workspace" \
        --argjson column "$column" '
        [
            .[]
            | select(
                .workspace_id == $workspace
                and .is_floating == false
                and .layout.pos_in_scrolling_layout != null
                and .layout.pos_in_scrolling_layout[0] == $column
            )
        ]
    ' <<< "$windows"
)"

target_windows="$(
    jq -c \
        --argjson workspace "$workspace" \
        --argjson column "$target_column" '
        [
            .[]
            | select(
                .workspace_id == $workspace
                and .is_floating == false
                and .layout.pos_in_scrolling_layout != null
                and .layout.pos_in_scrolling_layout[0] == $column
            )
        ]
    ' <<< "$windows"
)"

target_count="$(jq 'length' <<< "$target_windows")"
(( target_count > 0 )) || exit 0

output_height="$(
    niri msg -j focused-output |
        jq -r '.logical.height // empty'
)"

column_is_tabbed() {
    local column_json="$1"

    [[ -n "$output_height" ]] || return 1

    jq -e \
        --argjson height "$output_height" '
        length > 1
        and all(.[];
            .layout.tile_size[1] >= ($height * 0.75)
        )
    ' <<< "$column_json" >/dev/null
}

if column_is_tabbed "$source_windows" || column_is_tabbed "$target_windows"; then
    rm -f "$state"
    niri msg action "focus-column-$direction"
    exit 0
fi

target="$(
    jq -r \
        --argjson row "$desired_row" '
        sort_by(.layout.pos_in_scrolling_layout[1])
        | if length == 0 then
            empty
          else
            ([$row, length] | min) as $target_row
            | first(
                .[]
                | select(
                    .layout.pos_in_scrolling_layout[1] == $target_row
                )
              )
            | .id
          end
    ' <<< "$target_windows"
)"

[[ -n "$target" ]] || exit 0

niri msg action focus-window --id "$target"

if [[ "$using_remembered_row" == true ]]; then
    rm -f "$state"
fi

