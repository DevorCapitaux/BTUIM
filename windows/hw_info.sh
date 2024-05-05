#!/bin/bash

hw_padding=2

get_cpu_name() {
    cpu_name=$(cat /proc/cpuinfo | grep 'model name' | awk -F ':' 'END {print $2}')
}

get_cpu_info() {
    cpu_info=()
    while IFS= read -r line; do
        cpu_info+=("$line")
    done < <(iostat -c | awk 'NR > 1 && NF')
}

get_mem_info() {
    mem_info=()
    if (( window_width - hw_padding < 80 )); then
        while IFS= read -r line; do
            mem_info+=("$line")
        done < <(free -gh | awk \
            'NR==1 {printf "%-6s %-7s %-7s\n", "", $1, $2} \
            NR>1 {printf "%-6s %-7s %-7s\n", $1, $2, $3}')
    else
        while IFS= read -r line; do
            mem_info+=("$line")
        done < <(free -gh)
    fi
}

get_disk_info() {
    disk_info=()
    while IFS= read -r line; do
        disk_info+=("$line")
    done < <(iostat -d | awk 'NF && NR>1 \
        {printf "%-9s %-11s %-11s %-9s %-8s\n", $1, $3, $4, $6, $7}')
}


get_disk_part_info() {
    disk_part_info=()
    while IFS= read -r line; do
        disk_part_info+=("$line")
    done < <(lsblk -o name,size,type,fstype)
}

hw_shrinked_lines=0

draw_hw() {
    local x=$window_x
    local y=$window_y
    local width=$window_width
    local height=$window_height
    local padding=$hw_padding

    hw_shrinked_lines=0
    hw_bottom_reached=false
    local i=1

    if ! $hw_side_scroll; then
        draw_window_bg ${window_bg[@]}
    fi

    if (( hw_skip_sections < 1 )); then
        draw_header "CPU INFO" $((y + i))
        i=$((i + 2))

        move $((x + padding)) $((y + i))
        print_line_with_offset hw_shrinked_lines $hw_side_offset \
            "Model name:$cpu_name" $((width - 2 * padding))
        i=$((i + 2))

        local j
        for (( j = 0 ; j < ${#cpu_info[@]}; j++ )); do
            (( i + j > height - padding )) && return
            move $((x + padding)) $((y + i + j))
            print_line_with_offset hw_shrinked_lines $hw_side_offset \
                "${cpu_info[$j]}" $((width - 2 * padding))
        done
        i=$((i + j + 1))
    fi

    if (( hw_skip_sections < 2 )); then
        draw_header "MEMORY INFO" $((y + i))
        i=$((i + 2))

        for (( j = 0 ; j < ${#mem_info[@]}; j++ )); do
            (( i + j > height - padding )) && return
            move $((x + padding)) $((y + i + j))
            print_line_with_offset hw_shrinked_lines $hw_side_offset \
                "${mem_info[$j]}" $((width - 2 * padding))
        done
        i=$((i + j + 1))
    fi

    if (( hw_skip_sections < 3 )); then
        draw_header "DISK INFO" $((y + i))
        i=$((i + 2))

        for (( j = 0 ; j < ${#disk_info[@]}; j++ )); do
            (( i + j > height - padding )) && return
            move $((x + padding)) $((y + i + j))
            print_line_with_offset hw_shrinked_lines $hw_side_offset \
                "${disk_info[$j]}" $((width - 2 * padding))
        done
        i=$((i + j + 1))
    fi

    for (( j = 0 ; j < ${#disk_part_info[@]}; j++ )); do
        (( i + j > height - padding )) && return
        move $((x + padding)) $((y + i + j))
        print_line_with_offset hw_shrinked_lines $hw_side_offset \
            "${disk_part_info[$j]}" $((width - 2 * padding))
    done

    hw_bottom_reached=true
}

hw_scroll_right() {
    if (( hw_shrinked_lines > 0 )); then
        hw_side_offset=$((hw_side_offset + 1))
        hw_side_scroll=true
        draw_hw
        hw_side_scroll=false
    fi
}

hw_scroll_left() {
    if (( hw_side_offset > 0 )); then
        hw_side_offset=$((hw_side_offset - 1))
        hw_side_scroll=true
        draw_hw
        hw_side_scroll=false
    fi
}

hw_scroll_down() {
    if ! $hw_bottom_reached; then
        hw_skip_sections=$((hw_skip_sections + 1))
        draw_hw
    fi
}

hw_scroll_up() {
    if (( hw_skip_sections > 0 )); then
        hw_skip_sections=$((hw_skip_sections - 1))
        draw_hw
    fi
}

draw_hw_info_win() {
    # Do nothing if update == false
    $update || return

    hw_side_offset=0
    hw_skip_sections=0
    hw_bottom_reached=false
    hw_side_scroll=false

    get_cpu_name
    get_cpu_info
    get_mem_info
    get_disk_info
    get_disk_part_info

    draw_hw
}
