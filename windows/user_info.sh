#!/bin/bash

draw_user_win() {
    # Do nothing if update == false
    $update || return

    local x=$window_x
    local y=$window_y
    local width=$window_width
    local height=$window_height
    local side_padding=2

    draw_window_bg ${window_bg[@]}

    local user=$(whoami)
    local passwd=$(cat /etc/passwd | grep $user)
    IFS=':' read -ra info <<< "$passwd"
    local uid=${info[2]}
    local gid=${info[3]}
    local home=${info[5]}
    local shell=${info[6]}

    # Calculate pic_width
    local max_pic_width=$((width - 2 * side_padding))
    local max_pic_height=$((height - 6 * 2 - 2))
    local pic_width
    if (( max_pic_height < max_pic_width )); then
        pic_width=$((max_pic_height * 2))
    else
        pic_width=$max_pic_width
    fi

    local pic_margin=$(((width - pic_width) / 2))
    local pic_def_path="/var/lib/AccountsService/icons/$user"
    local pic_alt_path="pics/unknown_user.jpg"

    local pic_path
    if [[ -f $pic_def_path ]]; then
        pic_path=$pic_def_path
    else
        pic_path=$pic_alt_path
    fi
    local pic=$(jp2a --colors --width=$pic_width $pic_path | sed 's/\x1B\[0m//g')

    set_bg_color ${window_bg[@]}
    local i=1
    while IFS=$'\n' read -r line; do
        move $((x + pic_margin)) $((y + i))
        printf "%s" $line
        i=$((i + 1))
    done <<< "$pic"
    clear_colors

    set_bg_color ${window_bg[@]}

    move $((x + side_padding)) $((y + i + 2))
    printf "User: $user"
    move $((x + side_padding)) $((y + i + 4))
    printf "UID: $uid"
    move $((x + side_padding)) $((y + i + 6))
    printf "GID: $gid"
    move $((x + side_padding)) $((y + i + 8))
    printf "Home: $home"
    move $((x + side_padding)) $((y + i + 10))
    printf "Shell: $shell"

    clear_colors
}
