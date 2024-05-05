#!/bin/bash

source pics/big_flower.sh
source pics/small_flower.sh
source pics/jelly_fish.sh

bg_color=(30 30 47)

fill_bg() {
    local r=$1; local g=$2; local b=$3

    set_bg_color $r $g $b
    local i
    for (( i = 0; i < rows; i++ )); do
        printf "%${cols}s" ""
    done
    clear_colors
}

draw_pic() {
    local pic=$1
    local x=$2; local y=$3
    local width=$4; local height=$5
    # pic_color:
    local r=$6; local g=$7; local b=$8

    # Calculate top and bottom offsets
    if (( y < 0 )); then
        # Check if it is visible
        (( y + height < 0 )) && return

        height=$((height + y))
        y=0
    elif (( y + height > rows )); then
        # Check if it is visible
        (( y >= rows )) && return

        height=$((rows - y))
    fi

    local left_offset=0
    local right_offset=0
    if (( x < 0 )); then
        # Check if it is visible
        (( x + width < 0 )) && return

        left_offset=$((-1 * x))
        x=0
    elif (( x + width > cols )); then
        # Check if it is visible
        (( x >= cols )) && return

        right_offset=$((x + width - cols))
    fi

    move $x $y
    set_color $r $g $b
    set_bg_color ${bg_color[@]}
    local i
    for (( ; i < height; i++ )); do
        printf "%s" "${pic:$((i * width + left_offset)):$((width - left_offset - right_offset))}"
        move $x $((y + i + 1))
    done
    clear_colors
}

draw_jelly_fish() {
    local x=$1; local y=$2
    local width=$jelly_fish_w; local height=$jelly_fish_h
    # pic_color:
    local r=$3; local g=$4; local b=$5
    local diff_time=$6
    local interval=$7

    if (( diff_time > interval )); then
        diff_time=$((interval - 1))
    fi
    local frame=$((diff_time * jelly_fish_frame_num / interval))

    draw_pic "${jelly_fish[$frame]}" $x $y $width $height $r $g $b
}

draw_bg() {
    if $update && $resizing; then
        #Update background color on resize
        fill_bg ${bg_color[@]}

        local bf_color=(133 175 244)
        local bf_y=$((rows - 15))
        (( bf_y < 18 )) && bf_y=18
        draw_pic "$big_flower" -14 $bf_y $big_flower_w $big_flower_h ${bf_color[@]}

        local sf_color=(249 226 175)
        local sf_y=$((rows - 12))
        (( sf_y < 23 )) && sf_y=23
        draw_pic "$small_flower" $((cols - 36)) $sf_y $small_flower_w $small_flower_h ${sf_color[@]}
    fi

    local jf_diff_time=$((cur_time - jf_last_update))
    # This value shouldn't exceed delay value ( 1000 / fps )
    local jf_interval=1500
    local jf_frames=$jelly_fish_frame_num
    # This is ment not to miss any frame due to delay and inteval differences
    local jf_interval_corrected=$((jf_interval * jf_frames / (jf_frames + 1)))
    local jf_color=(187 154 187)
    if (( jf_diff_time >= $delay )); then
        draw_jelly_fish 0 0 ${jf_color[@]} $jf_diff_time $jf_interval
        draw_jelly_fish $((cols - jelly_fish_w)) 5 ${jf_color[@]} $jf_diff_time $jf_interval
        if (( jf_diff_time >= jf_interval_corrected )); then
            jf_last_update=$cur_time
        fi
    fi
}
