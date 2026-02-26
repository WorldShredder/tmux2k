#!/usr/bin/env bash

declare -A COLOR_GRADIENTS=(
    ['heat10']='#6673bc #5da9bc #54bd8e #56bd4c #78bd47 #9ebd43 #beb53e #be8b3a #be5d35 #be3136'
    ['heat4']='#6673bc #50bd69 #beb53e #be3136'
    ['cosmic10']='#6673bc #705dbc #8e54bd #b24cbd #bd47b3 #bd439e #be3e86 #be3a6d #be3552 #be3136'
    ['cosmic4']='#6673bc #a050bd #bd439e #be3136'
)

pct2color() {
    # Usage: pct2color [option ...] VALUE COLORS
    # 
    # Returns a HEX color from COLORS or COLOR_GRADIENTS based on a
    # given percentage, fraction, or range.
    #
    # Positional Args:
    #  VALUE   Value to measure. If value is not format 'X[.Y]%', a
    #          fraction is assumed. If range is given, then value
    #          becomes: value / range
    #  COLORS  Space-separated string of HEX colors, or key of a
    #          named gradient in array COLOR_GRADIENTS. Appending
    #          '-reverse' to key reverses the named gradient.
    #
    # Options:
    #  -r, --range NUM
    #          Defines the ceiling of a range from 0 to NUM, where
    #          VALUE becomes a number in range.
    #
    # Example:
    #  pct2color '66%'      '#0000ff #00ff00 #ff0000' => '#ff0000'
    #  pct2color -r 200 100 '#0000ff #ff0000'         => '#ff0000'
    #  pct2color 0.75       'heat10'                  => COLOR_GRADIENTS[heat10][6]
    #  pct2color 0.5%       '!cosmic4'                => COLOR_GRADIENTS[cosmic4][3]

    local range
    while :; do
        case "$1" in
            -r|--range) range="$2" ; shift ;;
            *) break ;;
        esac
        shift
    done

    local value="$1"
    local colors="$2"
    local reverse='false'
    if [[ "$colors" = \!* ]] ; then
        reverse='true'
        colors="${colors#*!}"
    fi

    [[ " ${!COLOR_GRADIENTS[@]} " =~ "${colors}" ]] &&\
        colors="${COLOR_GRADIENTS[$colors]}"

    if [ -n "$range" ] ; then
        ! value="$(awk "BEGIN {print int($value / $range * 100)}")" &&\
            return
    else
        ! [[ "${value// /}" = *'%' ]] &&\
            ! value="$(awk "BEGIN {print ${value} * 100}")" &&\
                return
        value="$(printf '%.0f' "${value%%\%*}")"
    fi

    [ -z "$value" ] || [ -z "$colors" ] &&\
        return

    if [ "$reverse" = 'true' ] ; then
        declare -a _colors=($colors)
        declare -a colors=()
        for ((i = ${#_colors[@]} - 1; i >= 0; i--)) ; do
            colors+=("${_colors[$i]}")
        done
        unset _colors
    else
        declare -a colors=($colors)
    fi

    local color="${colors[$((value * ${#colors[@]} / 100))]}"
    
    [ -z "$color" ] &&\
        color="${colors[-1]}"

    printf '%s' "$color"
}
