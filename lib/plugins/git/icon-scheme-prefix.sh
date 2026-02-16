#!/usr/bin/env bash

readonly -A STATUS_ICONS=(
    ['M']="$( get_tmux_value '@tmux2k-git-modified-icon'  '󰰏' )"
    ['A']="$( get_tmux_value '@tmux2k-git-added-icon'     '󰯫' )"
    ['D']="$( get_tmux_value '@tmux2k-git-deleted-icon'   '󰯴' )"
    ['U']="$( get_tmux_value '@tmux2k-git-updated-icon'   '󰰧' )"
    ['R']="$( get_tmux_value '@tmux2k-git-renamed-icon'   '󰰞' )"
    ['I']="$( get_tmux_value '@tmux2k-git-ignored-icon'   '󰰃' )"
    ['X']="$( get_tmux_value '@tmux2k-git-untracked-icon' '󰰰' )"
)

