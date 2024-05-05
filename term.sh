#!/bin/bash

init_scr() {
    tput smcup
    tput civis
    stty_bkp=$(stty -g)
    stty cbreak -echo time 0 min 0
}

reset_scr() {
    stty $stty_bkp
    tput cnorm
    tput rmcup
}

get_cols() {
    tput cols
}

get_rows() {
    tput lines
}

clear_scr() {
    tput clear
}

# move x y
move() {
    tput cup $2 $1
}

# set_color r g b
set_color() {
    printf "\e[38;2;%d;%d;%dm" $1 $2 $3
}

# set_bg_color r g b
set_bg_color() {
    printf "\e[48;2;%d;%d;%dm" $1 $2 $3
}

clear_colors() {
    printf "\e[0m"
}

set_bold_mode() {
    tput bold
}

set_italic_mode() {
    tput sitm
}

set_underline_mode() {
    tput smul
}
