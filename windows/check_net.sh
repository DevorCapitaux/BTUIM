#!/bin/bash

net_check_connection() {
    local succesfull_pings=0
    for (( i = 0; i < 5; i++ )); do
        ping -c 1 archlinux.org 2>/dev/null 1>&2
        if (( $? == 0 )); then
            succesfull_pings=$((succesfull_pings + 1))
        fi
    done

    if (( succesfull_pings > 0 )); then
        kill -USR1 $$
    else
        kill -USR2 $$
    fi
}

net_connection_status=""
net_connection_is_ok() {
    net_connection_status="Connection is ok!"
}
net_no_connection() {
    net_connection_status="No internet connection!"
}

draw_check_net_win() {
    if $update; then
        draw_window_bg ${window_bg[@]}

        net_result_printed=false
        net_connection_status=""
        net_start_time=$cur_time

        net_last_update=0
        net_loading_frame=0

        local rat_pic_width=833
        local rat_pic_height=233
        local width=$window_width
        local height=$window_height

        rat_width=$width
        rat_height=$((rat_width * rat_pic_height / rat_pic_width))

        if (( rat_height > height )); then
            rat_height=$height
            rat_width=$((rat_height * rat_pic_width / rat_pic_height))
        fi

        rat_frames=()
        rat_frame_num=12
        for i in {1..12}; do
            local pic_path="pics/rat/rat_${i}.png"
            local pic=$(jp2a --colors --height=${rat_height} \
                --width=${rat_width} $pic_path | sed 's/\x1B\[0m//g')
            rat_frames+=("$pic")
        done

        trap net_connection_is_ok SIGUSR1
        trap net_no_connection SIGUSR2
        net_check_connection &
    fi

    if [[ -n $net_connection_status ]] && (( cur_time - net_start_time > 2000 )); then
        if ! $net_result_printed; then
            draw_window_bg ${window_bg[@]}
            set_bg_color ${window_bg[@]}
            move $((window_x + (window_width - ${#net_connection_status}) / 2)) $((window_y + window_height / 2))
            printf "%s" "$net_connection_status"
            net_result_printed=true
            clear_colors
        fi
    elif (( cur_time - net_last_update >= $delay )); then
        net_last_update=$cur_time
        net_loading_frame=$((net_loading_frame + 1))
        (( net_loading_frame > rat_frame_num - 1 )) && net_loading_frame=0

        set_bg_color ${window_bg[@]}
        local pic=${rat_frames[$net_loading_frame]}
        local i
        while IFS=$'\n' read -r line; do
            move $window_x $((window_y + i))
            printf "%s" "$line"
            i=$((i + 1))
        done <<< "$pic"
    fi
    clear_colors
}
