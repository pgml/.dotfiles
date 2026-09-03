#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from socket import AF_UNIX, SOCK_STREAM, socket


def get_windows():
    output = subprocess.check_output(
        ["niri", "msg", "-j", "windows"],
        text=True,
    )
    return json.loads(output)


def send_actions(*actions):
    """
    actions:
        ("MoveColumnLeft", {})
        ("FocusWindow", {"id": 123})
        ...
    """

    requests = [
        json.dumps({"Action": {name: args}}, separators=(",", ":"))
        for name, args in actions
    ]

    with socket(AF_UNIX, SOCK_STREAM) as sock:
        sock.connect(os.environ["NIRI_SOCKET"])

        # Send everything in one write, like tilemod's batching.
        sock.sendall(("\n".join(requests) + "\n").encode())

        reader = sock.makefile("r")

        for name, _ in actions:
            response = json.loads(reader.readline())

            if "Err" in response:
                print(
                    f"niri action {name} failed: {response['Err']}",
                    file=sys.stderr,
                )


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("left", "right"):
        print(f"usage: {sys.argv[0]} left|right", file=sys.stderr)
        sys.exit(2)

    direction = sys.argv[1]

    windows = get_windows()

    focused = next(
        (window for window in windows if window["is_focused"]),
        None,
    )

    if focused is None:
        return

    pos = focused["layout"].get("pos_in_scrolling_layout")

    # Floating window, etc.
    if pos is None:
        return

    workspace = focused["workspace_id"]
    column, row = pos

    workspace_windows = [
        window
        for window in windows
        if window["workspace_id"] == workspace
        and not window["is_floating"]
        and window["layout"].get("pos_in_scrolling_layout") is not None
    ]

    current_column = [
        window
        for window in workspace_windows
        if window["layout"]["pos_in_scrolling_layout"][0] == column
    ]

    # ------------------------------------------------------------
    # One window in column:
    # move the whole column, never implicitly consume.
    # ------------------------------------------------------------

    if len(current_column) == 1:
        action = (
            "MoveColumnLeft"
            if direction == "left"
            else "MoveColumnRight"
        )

        send_actions((action, {}))
        return

    # ------------------------------------------------------------
    # Multiple windows:
    # find adjacent column.
    # ------------------------------------------------------------

    adjacent_column = (
        column - 1
        if direction == "left"
        else column + 1
    )

    adjacent_windows = [
        window
        for window in workspace_windows
        if window["layout"]["pos_in_scrolling_layout"][0]
        == adjacent_column
    ]

    # ------------------------------------------------------------
    # No adjacent column:
    # expel the focused window.
    # ------------------------------------------------------------

    if not adjacent_windows:
        action = (
            "ConsumeOrExpelWindowLeft"
            if direction == "left"
            else "ConsumeOrExpelWindowRight"
        )

        send_actions((action, {"id": focused["id"]}))
        return

    # ------------------------------------------------------------
    # Adjacent column exists:
    # swap with the window at the same row.
    #
    # If the other column is shorter, clamp to its last row.
    # ------------------------------------------------------------

    adjacent_windows.sort(
        key=lambda window:
            window["layout"]["pos_in_scrolling_layout"][1]
    )

    target_row = min(row, len(adjacent_windows))

    target = next(
        window
        for window in adjacent_windows
        if window["layout"]["pos_in_scrolling_layout"][1]
        == target_row
    )

    # We focus the *target* and swap in the opposite direction.
    #
    # Example:
    #
    #   [A] [C]
    #   [B] [D*]
    #
    # smart-move left:
    #
    #   focus B
    #   swap B right  -> swaps B with remembered D
    #   focus D
    #
    # Result:
    #
    #   [A] [C]
    #   [D*][B]

    swap_action = (
        "SwapWindowRight"
        if direction == "left"
        else "SwapWindowLeft"
    )

    send_actions(
        ("FocusWindow", {"id": target["id"]}),
        (swap_action, {}),
        ("FocusWindow", {"id": focused["id"]}),
    )


if __name__ == "__main__":
    main()
