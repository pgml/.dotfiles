#!/usr/bin/env bash

set -euo pipefail

direction="${1:-}"

case "$direction" in
    left|right) ;;
    *) exit 2 ;;
esac

windows="$(niri msg -j windows)"

focused="$(
    jq -c '
        first(.[] | select(.is_focused))
    ' <<< "$windows"
)"

[[ "$focused" != "null" && -n "$focused" ]] || exit 0

workspace="$(jq -r '.workspace_id // empty' <<< "$focused")"
column="$(jq -r '.layout.pos_in_scrolling_layout[0] // empty' <<< "$focused")"
row="$(jq -r '.layout.pos_in_scrolling_layout[1] // empty' <<< "$focused")"

# Floating window, no scrolling-layout position, etc.
[[ -n "$workspace" && -n "$column" && -n "$row" ]] || exit 0

if [[ "$direction" == "left" ]]; then
    target_column=$((column - 1))
else
    target_column=$((column + 1))
fi

# No possible column in that direction.
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

# Nothing to focus in that direction.
(( target_count > 0 )) || exit 0

# niri does not currently expose normal/tabbed column display mode through
# the window IPC. Infer tabbed columns from geometry instead:
#
# - a tabbed column has multiple windows
# - every tab occupies essentially the full output height
#
# A normal stacked column divides the available height between its rows.
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

# Tabbed columns have their own active-tab semantics. If either side is
# tabbed, defer completely to niri so entering a tabbed column restores
# its active/remembered tab instead of treating tab indices as spatial rows.
if column_is_tabbed "$source_windows" || column_is_tabbed "$target_windows"; then
    niri msg action "focus-column-$direction"
    exit 0
fi

# Ordinary stacked columns: preserve the current spatial row.
#
# If the target column has fewer rows, clamp to its bottom-most row.
target="$(
    jq -r \
        --argjson row "$row" '
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

# Direct ID focus avoids niri first jumping to the remembered row and then
# being corrected in a second visible step.
niri msg action focus-window --id "$target"

