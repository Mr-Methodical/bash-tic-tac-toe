#!/bin/bash
#./tictactoe.sh
board=(0 1 2 3 4 5 6 7 8)
print_array() {
    echo "   |   |   "
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "___|___|___"
    echo "   |   |   "
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "___|___|___"
    echo "   |   |   "
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo "   |   |   "
    echo "______________________________"
}

free_space_count() {
    local count=0;
    for i in 0 1 2 3 4 5 6 7 8; do
        if [[ ${board[i]} =~ ^[0-8]$ ]]; then
            ((count++))
        fi
    done
    echo ${count}
}

check_win() {
    char=${1} #either will be 'O' or 'X'
    for i in 0 3 6; do
        if [ ${char} == ${board[$((i))]} ] && \
           [ ${char} == ${board[$((i+1))]} ] && \
           [ ${char} == ${board[$((i+2))]} ]; then
            return 0 #for win
        fi
    done
    for i in 0 1 2; do
        if [ ${char} == ${board[$((i))]} ] && \
           [ ${char} == ${board[$((i+3))]} ] && \
           [ ${char} == ${board[$((i+6))]} ]; then
            return 0 #for win
        fi
    done
    if [ ${char} == ${board[0]} ] && \
       [ ${char} == ${board[4]} ] && \
       [ ${char} == ${board[8]} ]; then
        return 0 #for win
    fi
    
    if [ ${char} == ${board[2]} ] && \
       [ ${char} == ${board[4]} ] && \
       [ ${char} == ${board[6]} ]; then
        return 0 #for win
    fi
    return 1
}    

robot_choose() {
    local count=$(free_space_count)
    local free_index=$((RANDOM % count))
    local counter=0
    while [ ${free_index} -gt 0 ]; do
        if [[ ${board[counter]} =~ ^[0-8]$ ]]; then
            ((counter++))
            ((free_index--))
        else
            ((counter++))
        fi
    done
    board[counter]=$1
    print_array
    check_win $1
    if [ $? -eq 0 ]; then
        echo "computer wins"
        exit 0
    fi
}

board_full() {
    for i in {0..8}; do
        if [ ${board[$i]} -eq $i ]; then
            echo 0 #there is still room left on board
            return
        fi
    done
    echo 1
}

echo -n "Tic-Tac-Toe: Enter 1 for you to go to first, anything else to go second: "
read place
if [[ ${place} =~ ^[0-9]+$ ]] && [ ${place} -eq 1 ]; then
    echo "You go first"
    robo_char='O'
    human_char='X'
    print_array
else
    echo "I will go first"
    robo_char='X'
    human_char='O'
    robot_choose ${robo_char}
fi
human_move() {
    read -p "Make a move" move
    while [[ ! ${move} =~ ^[0-8]$ ]] || [[ ! ${board[${move}]} =~ ^[0-8]$ ]]; do
        echo"----------------------------"
        echo "not a valid move"
        print_array
        read -p "Make a move: " move
    done
}
while [ $(board_full) -eq 0 ] {
    board[$(human_move)]=${human_char}
    print_array
    check_win $human_char
    if [ $? -eq 0 ]; then
        echo "human wins"
    fi
    robot_choose ${robo_char}
done
