#!/usr/bin/env bash

set -euo pipefail

if [[ "$(niri msg -j overview-state | jq -r '.is_open')" == "true" ]]; then
    niri msg action close-window
    exit 0
fi

state="${XDG_RUNTIME_DIR:-/tmp}/niri-preferred-row.json"

before="$(niri msg -j focused-window)"

id="$(jq -r '.id // empty' <<< "$before")"
workspace="$(jq -r '.workspace_id // empty' <<< "$before")"
row="$(jq -r '.layout.pos_in_scrolling_layout[1] // empty' <<< "$before")"

[[ -n "$id" ]] || exit 0

# Floating window etc.: nothing useful to remember.
if [[ -z "$row" ]]; then
    niri msg action close-window
    exit
fi

niri msg action close-window

# Wait briefly for the client to actually disappear and niri to
# transfer focus. This only runs after explicitly closing a window.
for _ in {1..100}; do
    after="$(niri msg -j focused-window 2>/dev/null || true)"
    after_id="$(jq -r '.id // empty' <<< "$after" 2>/dev/null || true)"

    if [[ -n "$after_id" && "$after_id" != "$id" ]]; then
        after_workspace="$(jq -r '.workspace_id // empty' <<< "$after")"

        if [[ "$after_workspace" == "$workspace" ]]; then
            jq -n \
                --argjson workspace "$workspace" \
                --argjson anchor "$after_id" \
                --argjson row "$row" \
                '{
                    workspace_id: $workspace,
                    anchor_id: $anchor,
                    row: $row
                }' > "$state"
        fi

        exit 0
    fi

    sleep 0.01
done

rm -f "$state"
