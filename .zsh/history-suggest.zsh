typeset -g _HISTORY_BROWSING=0

# Resets history browsing state on every new prompt display.
function _reset_history_browsing() {
    _HISTORY_BROWSING=0
}
precmd_functions+=(_reset_history_browsing)

# Queries the history preview binary and renders the static match preview below the prompt.
function _update_history_preview() {
    if [[ -z "$BUFFER" ]]; then
        zle -M ""
        return
    fi

    local preview
	preview=$(~/.dotfiles/.local/bin/history-preview --preview "$BUFFER" "$COLUMNS" 2>/dev/null)

    if [[ -n "$preview" ]]; then
        zle -M "$preview"
    else
        zle -M ""
    fi
}

# Inserts a character into the line buffer, resets history navigation, and refreshes the preview.
function _custom_self_insert() {
    _HISTORY_BROWSING=0
    zle .self-insert
    _update_history_preview
}

# Deletes the previous character, resets history navigation, and refreshes the preview.
function _custom_backward_delete() {
    _HISTORY_BROWSING=0
    zle .backward-delete-char
    _update_history_preview
}

# Launches the history picker and accepts the selected line on Shift+Enter.
function _select_history_with_bubbletea() {
    if [[ -z "$BUFFER" ]]; then
        return
    fi
    zle -M ""

    # Clear any active ghost text from zsh-autosuggestions
    if (($+functions[_zsh_autosuggest_clear])); then
        _zsh_autosuggest_clear
    fi
    unset POSTDISPLAY

    # Keep the prompt visible and draw the picker immediately below its last line.
    local original_cursor=$CURSOR
    CURSOR=$#BUFFER
    zle -R
    printf '\r\n' > /dev/tty

    # Flush any pending key strokes
    while read -t 0 -k 1; do read -k 1; done

    local chosen picker_status=0
    chosen=$(~/.dotfiles/.local/bin/history-preview "$BUFFER") || picker_status=$?

    while read -t 0 -k 1; do read -k 1; done

    # The picker clears its rows before returning; resume at the prompt's last line.
    printf '\033[1A\r' > /dev/tty
    CURSOR=$original_cursor

    # Status 10 asks zsh to execute the selected command in this shell.
    if (( picker_status == 10 )) && [[ -n "$chosen" ]]; then
        BUFFER="$chosen"
        CURSOR=$#BUFFER
        _HISTORY_BROWSING=0
        unset POSTDISPLAY
        zle reset-prompt
        zle .accept-line
        return
    elif [[ -n "$chosen" ]]; then
        fc -R
        BUFFER="$chosen"
        CURSOR=$#BUFFER
        _HISTORY_BROWSING=0
    fi

    # Ensure no trailing suggestion or preview message sticks around
    unset POSTDISPLAY

    # Fetch clean suggestion for the new buffer if plugin exists
    if (($+functions[_zsh_autosuggest_fetch])); then
        _zsh_autosuggest_fetch
    fi

    zle reset-prompt
}

# Accepts and executes the current buffer while clearing preview text and resetting state.
function _custom_accept_line() {
    _HISTORY_BROWSING=0
    zle -M ""
    zle .accept-line
}

# Handles the Up arrow key by navigating history backwards when prompt is empty or history mode is active, or launching Bubble Tea when text is present.
function _arrow_up_handler() {
    if [[ "$_HISTORY_BROWSING" -eq 1 ]]; then
        zle .up-line-or-history
        zle -M ""
    elif [[ -z "$BUFFER" ]]; then
        _HISTORY_BROWSING=1
        zle .up-line-or-history
        zle -M ""
    else
        _select_history_with_bubbletea
    fi
}

# Handles the Down arrow key by navigating history forwards when history mode is active, or launching Bubble Tea when text is present.
function _arrow_down_handler() {
    if [[ "$_HISTORY_BROWSING" -eq 1 ]]; then
        zle .down-line-or-history
        zle -M ""
        if [[ -z "$BUFFER" ]]; then
            _HISTORY_BROWSING=0
        fi
    elif [[ -z "$BUFFER" ]]; then
        zle -M ""
    else
        _select_history_with_bubbletea
    fi
}

# Widgets registration
zle -N self-insert _custom_self_insert
zle -N backward-delete-char _custom_backward_delete
zle -N accept-line _custom_accept_line
zle -N _select_history_with_bubbletea
zle -N _arrow_up_handler
zle -N _arrow_down_handler

# Arrow key bindings
bindkey '^[[A' _arrow_up_handler
bindkey '^[OA' _arrow_up_handler
bindkey '^[[B' _arrow_down_handler
bindkey '^[OB' _arrow_down_handler
bindkey '^J' _arrow_down_handler
bindkey '^K' _arrow_up_handler
