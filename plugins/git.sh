#!/usr/bin/env bash

readonly current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

# A && B || C: handles A|B->false

readonly ICON_SCHEME="$(get_tmux_option '@tmux2k-git-icon-scheme' 'default')"
readonly ICON_SCHEMES=' simple files files-solid prefix prefix-solid '
[[ "$ICON_SCHEMES" =~ " $ICON_SCHEME " ]] \
    && source "$current_dir/../lib/plugins/git/icon-scheme-${ICON_SCHEME}.sh" \
    || source "$current_dir/../lib/plugins/git/icon-scheme-default.sh"

readonly ICON_CORE_SCHEME="$(get_tmux_option '@tmux2k-git-icon-core-scheme' 'default')"
readonly ICON_CORE_SCHEMES=''
[[ "$ICON_CORE_SCHEMES" =~ " $ICON_CORE_SCHEME " ]] \
    && source "$current_dir/../lib/plugins/git/icon-core-scheme-${ICON_SCHEME}.sh" \
    || source "$current_dir/../lib/plugins/git/icon-core-scheme-default.sh"

readonly STATUS_FILTER="$(  get_tmux_option '@tmux2k-git-status-filter'  'AMURDX' )"
readonly MERGE_MODIFIED="$( get_tmux_option '@tmux2k-git-merge-modified' 'false'  )"
readonly DISPLAY_STATUS="$( get_tmux_option '@tmux2k-git-display-status' 'false'  )"

status_enabled() {
    [[ "$STATUS_FILTER" =~ "$1" ]]
}

format_status() {
    local git_status="$1"

    declare -A status_ct
    declare -i status_ct['M']=0
    declare -i status_ct['A']=0
    declare -i status_ct['D']=0
    declare -i status_ct['U']=0
    declare -i status_ct['R']=0
    declare -i status_ct['I']=0
    declare -i status_ct['X']=0

    declare -a git_opts=('-s')
    status_enabled 'I' &&\
        git_opts+=('--ignored')

    # TODO: Parse git status columns independently for implementation of
    # better grouped modes, e.g.: STAGED|UNSTAGED, INDEXED|UNINDEXED

    local file_status
    while read -r file_status; do
        case "$file_status" in
            [MADU])
                status_enabled "$file_status" &&\
                    status_ct["$file_status"]+=1 ;;
            '!!')
                status_enabled 'I' &&\
                    status_ct['I']+=1 ;;
            '??')
                status_enabled 'X' &&\
                    status_ct['X']+=1 ;;
            [RCT])
                status_enabled 'R' &&\
                    [ "$MERGE_MODIFIED" = 'true' ] \
                        && status_ct['M']+=1 \
                        || status_ct['R']+=1 ;;
        esac
    done <<< "$git_status"

    local output=''
    local i filter status_value
    while read -rn1 filter ; do
        [ -z "$filter" ] &&\
            continue
        status_value="${status_ct[$filter]}"
        [ "$status_value" -gt 0 ] &&\
            output+="${STATUS_ICONS[$filter]} $status_value "
    done <<< "$STATUS_FILTER"

    printf '%s' "${output% *}"
}

format_branch() {
    local git_branch="$1"
    printf "%.20s " "$git_branch"
}

get_branch() {
    local branch
    branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)" &&\
        format_branch "$branch"
}

get_status() {
    # TODO: Capture X and Y status columns separately
    declare -a git_opts=('-s')
    status_enabled 'I' &&\
        git_opts+=('--ignored')
    git -C "$path" status "${git_opts[@]}" | awk '{print $1}'
}

get_output() {
    local branch
    branch="$(get_branch)"
    if [ -z "$branch" ] ; then
        printf '%s' "${CORE_ICONS[no_repo]}"
        return
    fi

    local git_status
    git_status="$(get_status)"
    if [ -z "$git_status" ] ; then
        printf '%s' "${CORE_ICONS[repo]} $branch"
        return
    fi

    local status_line
    status_line="$(format_status "$git_status")"

    if [ "$DISPLAY_STATUS" == 'false' ]; then
        echo "$status_line ${CORE_ICONS[diff]} $branch"
    else
        echo "${CORE_ICONS[diff]} $branch"
    fi
}

print_output() {
    normalize() { printf '%s' "$*"; }
    normalize $1
}

main() {
    local path git_status
    path="$(get_pane_dir)"
    print_output "$(get_output)"
}

main

