#!/usr/bin/env bash

readonly -A CORE_ICONS=(
    ['diff']="$(    get_tmux_value  '@tmux2k-git-diff-icon'      '' )"
    ['repo']="$(    get_tmux_value  '@tmux2k-git-repo-icon'      '' )"
    ['no_repo']="$( get_tmux_option '@tmux2k-git-no-repo-icon'   '' )"
)

