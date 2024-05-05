#!/bin/bash
ESC=$'\e'
UP=$'\033[A'
DOWN=$'\033[B'
RIGHT=$'\033[C'
LEFT=$'\033[D'

handle_keypress() {
    eof=false
    IFS= read -r key || eof=true

    case $cur_window in
        menu)
            case $key in
                $DOWN|j) menu_item_next ;;
                $UP|k) menu_item_prev ;;
                $ESC|q) running=false ;;
            esac

            # Enter key
            if ! $eof [[ $key == "" ]]; then
                local win=${menu_item_windows[menu_selected + menu_offset]}
                cur_window=$win
                update=true

                (( win == "env" )) && env_offset=0 && env_selected=0
            fi
        ;;
        env)
            case $key in
                $DOWN|j) env_line_next ;;
                $UP|k) env_line_prev ;;
            esac

            # Enter key
            if ! $eof && [[ $key == "" ]]; then
                cur_window="env_val"
                update=true
            fi
        ;;& # Plus defualt keymaps
        env_val)
            case $key in
                $DOWN|j) env_val_scroll_down ;;
                $UP|k) env_val_scroll_up ;;
                $ESC|q|b)
                    env_val_offset=0
                    cur_window="env"
                    update=true
                ;;
            esac
        ;;
        hw_info)
            case $key in
                $RIGHT|l) hw_scroll_right ;;
                $LEFT|h) hw_scroll_left ;;
                $DOWN|j) hw_scroll_down ;;
                $UP|k) hw_scroll_up ;;
            esac
        ;;& # Plus defualt keymaps
        proc)
            case $key in
                $RIGHT|l)proc_scroll_right ;;
                $LEFT|h) proc_scroll_left ;;
                $DOWN|j) proc_scroll_down ;;
                $UP|k) proc_scroll_up ;;
            esac
        ;;& # Plus defualt keymaps
        *)  # Defualt keymaps
            case $key in
                $ESC|q|b)
                    cur_window="menu"
                    update=true
                ;;
            esac
        ;;
    esac
}
