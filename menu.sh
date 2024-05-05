#!/bin/bash

menu_item_bg=( 36 36 57 )
menu_item_selected_bg=( 24 24 38 )

menu_item_height=3
menu_item_spacing=1
menu_padding=1
menu_scrolloff=1

menu_offset=0
menu_selected=0

menu_items=(
    "User information"
    "Environments variables"
    "Hardware information"
    "Check internet connection"
    "Get external IP"
    "Processes"
)

menu_item_windows=(
    "user"
    "env"
    "hw_info"
    "check_net"
    "get_ip"
    "proc"
)

draw_menu_item() {
    local vis_ind=$1    # Index of a visible item (add offset to get actual index)
    local selected=$2   # Boolean
    local text="${menu_items[$((vis_ind + menu_offset))]}"

    local margin=2
    local padding=1
    local width=$((window_width - 2 * margin))
    local height=$menu_item_height
    local spacing=$menu_item_spacing
    local x=$((window_x + margin))
    local y=$((window_y + margin / 2 + (height + spacing) * vis_ind))

    if $selected; then
        set_bg_color ${menu_item_selected_bg[@]}
    else
        set_bg_color ${menu_item_bg[@]}
    fi

    # Print menu item background
    local i
    for (( i = 0; i < height; i++ )); do
        move $x $((y + i))
        printf "%${width}s" ""
    done

    # Shrink menu item text to fit the menu width
    local text_width=${#text}
    if (( text_width > (width - 2 * padding) )); then
        text="${text:0:$(($width - 2 * padding - 3))}..."
    fi

    # Print menu item text
    move $((x + (width - ${#text}) / 2)) $((y + height / 2))
    printf "$text"

    clear_colors
}

draw_menu_items() {
    local i
    for (( i = 0; i < menu_visible_num; i++ )); do
        local selected=false
        (( i == menu_selected )) && selected=true

        draw_menu_item $i $selected
    done
}

menu_item_next() {
    select_next draw_menu_items draw_menu_item \
        menu_selected menu_offset \
        $menu_visible_num $menu_num $menu_scrolloff
}

menu_item_prev() {
    select_prev draw_menu_items draw_menu_item \
        menu_selected menu_offset \
        $menu_visible_num $menu_num $menu_scrolloff
}

draw_menu_win() {
    # Do nothing if update == false
    $update || return

    draw_window_bg ${window_bg[@]}

    menu_num=${#menu_items[@]}

    get_visible_items_num menu_visible_num $menu_num $menu_padding \
        $menu_item_height $menu_item_spacing

    # Changes the offset and selected index on resize
    correct_visible_selection menu_selected menu_offset $menu_visible_num \
        $menu_num $menu_scrolloff

    draw_menu_items
}
