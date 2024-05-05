#!/bin/bash

source term.sh
source key_handler.sh
source resize.sh

source background.sh
source menu.sh

source window.sh
source windows/user_info.sh
source windows/env_vars.sh
source windows/hw_info.sh
source windows/check_net.sh
source windows/get_ip.sh
source windows/proc.sh

fps=10
min_width=90
min_height=24

delay=$((1000 / fps))
running=true
update=true
resizing=true
cur_window="menu"

print_usage() {
    printf "Usage: bash_tui_menu [options]\n"
    printf "    -q --quiet  Do not play music\n"
}

play_soundtrack=true

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -q|--quiet) play_soundtrack=false ;;
        *)
            print_usage
            exit 1
        ;;
    esac
    shift
done

init_scr

if $play_soundtrack; then
    play ./samples/chase_song_loop.mp3 repeat 99999 2>/dev/null 1>&2 &
fi
soundtrack_pid=$!
while $running; do
    new_cols=$(get_cols)
    new_rows=$(get_rows)
    if (( new_cols != cols || new_rows != rows )); then
        cols=$new_cols
        rows=$new_rows

        update_window_params
        update=true
        resizing=true
        clear_scr
    fi

    if (( cols < min_width || rows < min_height )); then
        draw_resize
        continue
    fi

    cur_time=$(date +%s%3N)
    draw_bg
    case $cur_window in
        menu) draw_menu_win ;;
        user) draw_user_win ;;
        env) draw_env_win ;;
        env_val) draw_env_val_win ;;
        hw_info) draw_hw_info_win ;;
        check_net) draw_check_net_win ;;
        get_ip) draw_ip_win ;;
        proc) draw_proc_win ;;
    esac
    update=false
    resizing=false

    handle_keypress
done

# Stop soundtrack if it is playing
if [[ -n $soundtrack_pid ]]; then
    kill $soundtrack_pid
fi

reset_scr
