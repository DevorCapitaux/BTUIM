#!/bib/bash

proc_padding=2
proc_offset=0

get_proc_tbl() {
    ps_tbl=()
    while IFS= read -r line; do
        ps_tbl+=("$line")
    done < <(ps -a -o comm,pid,tname,euid,uid,%cpu,pmem,time,stime)
}

draw_proc() {
    local x=$window_x
    local y=$window_y
    local width=$window_width
    local padding=$proc_padding

    proc_shrinked_lines=0

    if ! $proc_scroll; then
        draw_window_bg ${window_bg[@]}
    fi

    local i=1
    draw_header "User Processes" $((y + i))
    i=$((i + 2))

    local j
    for (( j = 0; j < $proc_visible_num; j++ )); do
        move $((x + padding)) $((y + i + j))
        print_line_with_offset proc_shrinked_lines $proc_side_offset \
            "${ps_tbl[$((j + proc_offset))]}" $((width - 2 * padding))
    done
}

proc_scroll_right() {
    if (( proc_shrinked_lines > 0 )); then
        proc_side_offset=$((proc_side_offset + 1))
        proc_scroll=true
        draw_proc
        proc_scroll=false
    fi
}

proc_scroll_left() {
    if (( proc_side_offset > 0 )); then
        proc_side_offset=$((proc_side_offset - 1))
        proc_scroll=true
        draw_proc
        proc_scroll=false
    fi
}

proc_scroll_down() {
    proc_scroll=true
    scroll_down draw_proc proc_offset $proc_visible_num ${#ps_tbl[@]}
    proc_scroll=false
}

proc_scroll_up() {
    proc_scroll=true
    scroll_up draw_proc proc_offset $proc_visible_num ${#ps_tbl[@]}
    proc_scroll=false
}

draw_proc_win() {
    # Do nothing if update == false
    $update || return

    proc_side_offset=0
    proc_scroll=false

    get_proc_tbl

    proc_offset=0
    proc_visible_num=$((window_height - proc_padding - 3))
    (( proc_visible_num > ${#ps_tbl[@]} )) && proc_visible_num=${#ps_tbl[@]}

    draw_proc
}
