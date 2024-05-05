#!/bin/bash

draw_ip_win() {
    # Do nothing if update == false
    $update || return

    draw_window_bg ${window_bg[@]}

    local ip_add=$(wget -qO- ifconfig.me)

    set_bg_color ${window_bg[@]}
    if [[ $ip_add =~ ^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])\.?){4}$ ]]; then
        move $((window_x + (window_width - ${#ip_add}) / 2)) $((window_y + window_height / 2))
        printf "%s" "$ip_add"
    else
        local msg="No internet connection!"
        move $((window_x + (window_width - ${#msg}) / 2)) $((window_y + window_height / 2))
        printf "%s" "$msg"
    fi
    clear_colors
}
