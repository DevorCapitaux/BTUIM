#!/bin/bash

correct_color=(166 227 161)
incorrect_color=(243 139 168)

draw_resize() {
    # Do nothing if update == false
    $update || return

    size_line=$((${#cols} + ${#rows} + 1))
    move $(((cols - size_line) / 2)) $((rows / 2))

    if (( cols < min_width )); then
        set_color ${incorrect_color[@]}
    else
        set_color ${correct_color[@]}
    fi

    printf $cols

    clear_colors

    printf "x"

    if (( rows < min_height )); then
        set_color ${incorrect_color[@]}
    else
        set_color ${correct_color[@]}
    fi

    printf $rows

    clear_colors
}
