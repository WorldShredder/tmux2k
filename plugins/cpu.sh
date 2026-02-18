#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

readonly current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

cpu_display_load="$(get_tmux_option "@tmux2k-cpu-display-load" 'false')"

get_cpu_usage() {
    local output=''
    local percent=''

    case "$(uname -s)" in
    Linux)
        percent="$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 | grep "Cpu(s)" | tail -1 |\
                  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')"
        ;;

    Darwin)
        local cpuvalues cpucores cpuusage
        cpuvalue="$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')"
        cpucores="$(getconf _NPROCESSORS_ONLN)"
        cpuusage="$((cpuvalue / cpucores))"
        percent="$cpuusage"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    [ -z "$percent" ] &&\
        return

    if [ "$cpu_show_decimal" = 'true' ] ; then
        output+="$(normalize_padding "${percent}%" 5)"
    else
        output+="$(normalize_padding "${percent%.*}%" 4)"
    fi

    printf '%s' "$output"
}

normalize_load() {
    local value="$1"
    case "$(uname -s)" in
        Linux | Darwin)
            local cpucores
            cpucores="$(getconf _NPROCESSORS_ONLN)"
            awk "BEGIN {print substr($value / $cpucores, 1, 4)}"
            ;;
        CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

float_to_percent() {
    local value="$1"
    case "$(uname -s)" in
        Linux | Darwin)
            awk "BEGIN {print int($value * 100)\"%\"}"
            ;;
        CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

get_cpu_load() {
    declare -a output=()

    case $(uname -s) in
    Linux | Darwin)
        declare -a loadavg=()
        loadavg+=($(uptime | awk -F'[a-z]:' '{ print $2}' | sed 's/,//g'))

        local i avg
        declare -a time_win=('1m' '5m' '15m')
        for ((i = 0; i < "${#time_win[@]}"; i++)); do
            ! [[ " ${cpu_load_averages[@]} " =~ " ${time_win[$i]} " ]] &&\
                continue
            avg="${loadavg[$i]}"
            [ "$cpu_load_normalize" = 'true' ] &&\
                avg="$(normalize_load "$avg")"
            [ "$cpu_load_percent" = 'true' ] &&\
                avg="$(float_to_percent "$avg")"
            output+=("$(normalize_padding "$avg" 4)")
        done
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    printf '%s' "${output[*]}"
}

main() {
    if [ "$cpu_display_load" = 'true' ]; then
        cpu_load_normalize="$(get_tmux_option '@tmux2k-cpu-load-normalize' 'true')"
        cpu_load_percent="$(get_tmux_option '@tmux2k-cpu-load-percent' 'true')"
        cpu_load_averages=($(get_tmux_option '@tmux2k-cpu-load-averages' '1m 5m 15m'))
        get_cpu_load
    else
        cpu_icon="$(get_tmux_option '@tmux2k-cpu-icon' '')"
        cpu_show_decimal="$(get_tmux_option '@tmux2k-cpu-show-decimal' 'true')"
        local cpu_percent
        cpu_percent=$(get_cpu_usage)
        printf '%s' "$cpu_icon $cpu_percent"
    fi
}

main

