#!/bin/bash
#./rando_opponent.sh <program1> <program2> [num_games]
# Program 1 and 2 should both be algorithms for tic tac toe
# this script will run both against a random tic tac toe bot a specified 
# number of times and then will return how many nodes program 1 visted
# and how many nodes program 2 visited (it will also say how many games
# each program won)
# Default for num_games is 100

readonly PROG1="$1"
readonly PROG2="$2"
readonly NUM_GAMES="${3:-100}" #default is 100
board=(0 1 2 3 4 5 6 7 8)
program1_wins=0
program2_wins=0
program1_nodes_visited=0
program2_nodes_visited=0
free_space_count() {
    local count=0;
    for i in 0 1 2 3 4 5 6 7 8; do
        if [[ ${board[i]} =~ ^[0-8]$ ]]; then
            ((count++))
        fi
    done
    echo ${count}
}

reset_board() {
    board=(0 1 2 3 4 5 6 7 8)
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

robot_choose_smart() {
    local move=$("$1" "${board[@]}" 'O' 2> error.log) #$1 for which program to run
    if [ "$PROG1" == "$1" ]; then
        ((program1_nodes_visited+=$(cat error.log)))
    else 
        ((program2_nodes_visited+=$(cat error.log)))
    fi
    rm error.log
    board[${move}]='O'
    check_win 'O'
    if [ $? -eq 0 ]; then #case the algo has won
        if [ "$PROG1" == "$1" ]; then
            ((program1_wins++))
        else
            ((program2_wins++))
        fi
        return 0 #the robot won
    fi
}

robot_choose() {
    local free_spaces_left=$(free_space_count)
    local free_index=$((RANDOM % free_spaces_left))
    # we want the free_indexth space to be where the robot goes
    for i in {0..8}; do
        # case where the spot is a free space and we are on index we want
        if [[ ${board[$i]} =~ ^[0-8]$ ]] && [ $free_index -eq 0 ]; then
            board[$i]='X'
            break
        # not the right index, but it is free square:
        elif [[ ${board[$i]} =~ ^[0-8]$ ]]; then
            ((free_index--))
        fi
        # not free square so we don't do anything, move onto next index
    done
    #the random_choose can never win against a perfect algo, so no need to check
}

board_full() {
    for i in {0..8}; do
        if [[ ${board[$i]} =~ ^[0-8]$ ]]; then
            echo 0 #there is still room left on board
            return
        fi
    done
    echo 1
}

play_match() {
    reset_board
    local turn=$(($RANDOM % 2))
    if [ $turn -eq 0 ]; then
        robot_choose
    fi
    local smart_won=1
    while [ $smart_won -eq 1 ]; do
        if [ $(board_full) -eq 1 ]; then
            return
        fi
        robot_choose_smart $1
        if [ $? -eq 0 ]; then
            return
        fi
        if [ $(board_full) -eq 1 ]; then
            return
        fi
        robot_choose
    done
}

for ((games=1; games<=NUM_GAMES; games++)); do
    play_match "$PROG1"
    play_match "$PROG2"
done

echo "$1 visited $program1_nodes_visited nodes and it won "\ 
"$program1_wins games and tied $(($NUM_GAMES - $program1_wins))" 
echo "$2 visited $program2_nodes_visited nodes and it won "\
"$program2_wins games and tied $(($NUM_GAMES - $program2_wins))" 
exit 0
