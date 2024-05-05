#!/bin/bash

window_bg=( 28 28 44 )
window_margin=2
window_width=$((cols - 60))
window_height=$((rows - 2 * window_margin))
window_x=$(((cols - window_width) / 2))
window_y=$window_margin

update_window_params() {
    window_width=$((cols - 60))
    window_height=$((rows - 2 * window_margin))
    window_x=$(((cols - window_width) / 2))
}

draw_window_bg() {
    set_bg_color $1 $2 $3
    local i
    for (( i = 0; i < window_height; i++ )); do
        move $window_x $((window_y + i))
        printf "%${window_width}s" ""
    done
    clear_colors
}

draw_header() {
    local header=$1
    local y=$2

    set_bg_color ${window_bg[@]}
    set_bold_mode
    set_underline_mode

    move $((window_x + (window_width - ${#header}) / 2)) $y
    printf "%s" "$header"

    clear_colors
}

print_line_with_offset() {
    local -n shrinked_lines=$1
    local side_offset=$2
    local text=$3
    local max_width=$4

    local text=$(echo "$text" | sed "s/\t/    /g")

    set_bg_color ${window_bg[@]}
    if (( ${#text} - side_offset > max_width )); then
        shrinked_lines=$((shrinked_lines + 1))
        printf "%s" "${text:$side_offset:$((max_width - 1))}"
        set_bold_mode
        printf ">"
    else
        printf "%-${max_width}s" "${text:$side_offset}"
    fi
    clear_colors
}

# For scrollable menus (with selected item and scrolloff):

get_visible_items_num() {
    # Output parameter
    local -n visible_num=$1

    local num=$2
    local padding=$3
    local item_height=$4
    local spacing=$5
    
    local height=$window_height

    visible_num=$(((height + spacing - 2 * padding) / (item_height + spacing)))
    (( visible_num > num )) && visible_num=$num
}

correct_visible_selection() {
    # Output parameters
    local -n selected=$1
    local -n offset=$2

    local visible_num=$3
    local num=$4
    local scrolloff=$5

    # index = sel_1 + off_1 = sel_2 + off_2
    local index=$((selected + offset))

    if (( index <= visible_num - scrolloff - 1 )); then
        selected=$index
        offset=0
        return
    fi

    local remain=$((num - index - 1))
    if (( scrolloff < remain )); then
        selected=$((visible_num - scrolloff - 1))
    else
        selected=$((visible_num - remain - 1))
    fi
    offset=$((index - selected))
}

select_next() {
    # Function with sig: f()
    local draw_menu=$1
    # Function with sig: f(visible_index, selected)
    local draw_item=$2

    local -n selected=$3
    local -n offset=$4

    local visible_num=$5
    local num=$6
    local scrolloff=$7

    # If current item is on scrolloff
    if (( selected == visible_num - scrolloff - 1 )); then
        # And the list is not fully scrolled down
        if (( num - visible_num - offset > 0 )); then
            # Scroll and redraw list completely
            offset=$((offset + 1))
            $draw_menu
            return
        fi
    fi

    # If current item is not the last
    if (( selected != visible_num - 1 )); then
        # Redraw previous item
        $draw_item $selected false
        # Select next one
        selected=$((selected + 1))
        # Draw current item
        $draw_item $selected true
    fi
}

select_prev() {
    # Function with sig: f()
    local draw_menu=$1
    # Function with sig: f(visible_index, selected)
    local draw_item=$2

    local -n selected=$3
    local -n offset=$4

    local visible_num=$5
    local num=$6
    local scrolloff=$7

    # If current item is on scrolloff
    if (( selected == scrolloff )); then
        # And the list is not fully scrolled up
        if (( offset > 0 )); then
            # Scroll and redraw list completely
            offset=$((offset - 1))
            $draw_menu
            return
        fi
    fi

    # If current item is not the first
    if (( selected != 0 )); then
        # Redraw previous item
        $draw_item $selected false
        # Select previous one
        selected=$((selected - 1))
        # Draw current item
        $draw_item $selected true
    fi
}

# For scrollable windows:

correct_offset() {
    local -n offset=$1

    local visible_num=$2
    local num=$3
    local o=$offset

    if (( num <= visible_num )); then
        offset=0
    elif (( visible_num + offset > num - 1 )); then
        offset=$((num - visible_num))
    fi
}

scroll_down() {
    # Function with sig: f()
    local draw_menu=$1

    local -n offset=$2

    local visible_num=$3
    local num=$4

    # If no need to scroll - return
    (( num - offset <= visible_num )) && return

    offset=$((offset + 1))
    $draw_menu
}

scroll_up() {
    # Function with sig: f()
    local draw_menu=$1

    local -n offset=$2

    local visible_num=$3
    local num=$4

    # If no need to scroll - return
    (( offset == 0 )) && return

    offset=$((offset - 1))
    $draw_menu
}
