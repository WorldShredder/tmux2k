#!/usr/bin/env bash

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value="$(tmux show-option -gqv "$option")"
    if [ -z "$option_value" ]; then
        printf '%s' "$default_value"
    else
        printf '%s' "$option_value"
    fi
}

get_tmux_value() {
    # Like get_tmux_option(), but only fails when var is unset
    local option="$1"
    local default_value="$2"
    local option_value
    if option_value="$(tmux show-option -gv "$option" 2>/dev/null)" ; then
        printf '%s' "$option_value"
    else
        printf '%s' "$default_value"
    fi
}

normalize_padding() {
    percent_len="${#1}"
    max_len="${2:-4}"
    let diff_len="$max_len"-"$percent_len"
    # if the diff_len is even, left will have 1 more space than right
    let left_spaces=("$diff_len" + 1)/2
    let right_spaces=("$diff_len")/2
    printf "%${left_spaces}s%s%${right_spaces}s\n" "" "$1" ""
}

get_pane_dir() {
    nextone="false"
    ret=""
    for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
        [ "$i" == "1" ] && nextone="true" && continue
        [ "$i" == "0" ] && nextone="false"
        [ "$nextone" == "true" ] && ret+="$i "
    done
    echo "${ret%?}"
}

