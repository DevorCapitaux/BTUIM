#!/bin/bash

env_var_bg_color_1=( 36 36 57 )
env_var_bg_color_2=( 30 30 50 )
env_var_color_1=( 166 173 200 )
env_var_color_2=( 127 132 156 )
env_var_selected_color=( 24 24 38 )

table_line_height=1
table_line_spacing=0
table_margin=2
table_padding=1
env_scrolloff=5

env_offset=0
env_selected=0

draw_env_line() {
    local vis_ind=$1    # Index of a visible item (add offset to get actual index)
    local selected=$2   # Boolean
    local margin=$table_margin
    local padding=$table_padding
    local x=$((window_x + margin))
    local y=$((window_y + vis_ind + 1))

    if $selected; then
        set_bg_color ${env_var_selected_color[@]}
        set_bold_mode
        set_italic_mode
    elif (( vis_ind % 2 == 0 )); then
        set_color ${env_var_color_1[@]}
        set_bg_color ${env_var_bg_color_1[@]}
    else
        set_color ${env_var_color_2[@]}
        set_bg_color ${env_var_bg_color_2[@]}
    fi

    move $x $y

    local name="${env_names[$((vis_ind + env_offset))]}"

    # If there is enough space for var value
    if (( var_value_width > 0 )); then
        local value=${env_values[$((vis_ind + env_offset))]}
        # Shrink var value to fit its maximum width
        if (( ${#value} > (var_value_width - 2 * padding) )); then
            value="${value:0:$((var_value_width - 2 * padding - 3))}..."
        fi

        printf "%-${var_name_width}s" " $name"
        printf "%-${var_value_width}s" " $value"
    else
        # Shrink var name to fit its maximum width
        if (( ${#name} > (var_name_width - 2 * padding) )); then
            name="${name:0:$((var_name_width - 2 * padding - 3))}..."
        fi
        printf "%-${var_name_width}s" " $name"
    fi

    clear_colors
}

draw_env_table() {
    local i
    for (( i = 0; i < env_visible_num; i++ )); do
        local selected=false
        (( i == env_selected )) && selected=true

        draw_env_line $i $selected
    done
}

env_line_next() {
    select_next draw_env_table draw_env_line \
        env_selected env_offset \
        $env_visible_num $env_num $env_scrolloff
}

env_line_prev() {
    select_prev draw_env_table draw_env_line \
        env_selected env_offset \
        $env_visible_num $env_num $env_scrolloff
}

draw_env_win() {
    # Do nothing if update == false
    $update || return

    local x=$window_x
    local y=$window_y
    local width=$window_width
    local height=$window_height

    draw_window_bg ${window_bg[@]}

    env_names=()
    env_values=()
    while IFS='=' read -r name value; do
        env_names+=("$name")
        env_values+=("$value")
    done < <(env)
    env_num=${#env_names[@]}

    get_visible_items_num env_visible_num $env_num $table_padding \
        $table_line_height $table_line_spacing

    # Changes the offset and selected index on resize
    correct_visible_selection env_selected env_offset $env_visible_num \
        $env_num $env_scrolloff

    var_name_width=5    # Minimum width of a var name
    var_value_width=9   # Minimum width of a var value

    # Calculate env var maximum len
    for var in ${env_names[@]}; do
        local var_len=${#var}
        (( var_len > var_name_width )) && var_name_width=$var_len
    done
    # Add padding
    var_name_width=$((var_name_width + table_padding + 1))

    # If there is not enough space for var value, show only var name
    if (( var_name_width + var_value_width > width - 2 * table_margin )); then
        var_name_width=$((width - 2 * table_margin))
        var_value_width=0
    else
        var_value_width=$((width - 2 * table_margin - var_name_width))
    fi

    draw_env_table
}

env_val_offset=0

draw_env_val() {
    set_bg_color ${window_bg[@]}

    for (( i = 0; i < env_val_visible_line_num; i++ )); do
        move $((window_x + table_margin)) $((window_y + table_margin / 2 + i))

        # If window is scrolled down, show `...` in the first line
        if (( i == 0 && env_val_offset > 0 )); then
            printf "%s" \
                "...${env_val:$(((i + env_val_offset) * env_val_max_width + 3)):\
                $((env_val_max_width - 3))}"
            continue
        fi
        # If window could be scrolled down, show `...` in the last line
        if (( i == env_val_visible_line_num - 1 && i + env_val_offset < env_val_line_num - 1 )); then
            printf "%s" \
                "${env_val:$(((i + env_val_offset) * env_val_max_width)):\
                $((env_val_max_width - 3))}..."
            continue
        fi

        printf "%-${env_val_max_width}s" "${env_val:$(((i + env_val_offset) * env_val_max_width)):env_val_max_width}"
    done

    clear_colors
}

env_val_scroll_down() {
    scroll_down draw_env_val env_val_offset $env_val_visible_line_num $env_val_line_num
}

env_val_scroll_up() {
    scroll_up draw_env_val env_val_offset $env_val_visible_line_num $env_val_line_num
}

draw_env_val_win() {
    # Do nothing if update == false
    $update || return

    draw_window_bg ${window_bg[@]}

    env_val=${env_values[$((env_selected + env_offset))]}
    env_val_width=${#env_val}
    env_val_max_width=$((window_width - 2 * table_margin))

    env_val_line_num=$((env_val_width / env_val_max_width + 1))
    get_visible_items_num env_val_visible_line_num $env_val_line_num 1 1 0

    correct_offset env_val_offset $env_val_visible_line_num $env_val_line_num

    draw_env_val
}
