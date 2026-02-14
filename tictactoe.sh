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
}

free_space_count() {
    count=0;
    for i in 0 1 2 3 4 5 6 7 8; do
        if [[ ${board[i]} =~ ^[0-8]$ ]]; then
            ((count++))
        fi
    done
    echo ${count}
}

#robot_choose()

echo -n "Tic-Tac-Toe: Enter 1 for you to go to first, anything else to go second: "
read place
if [[ ${place} =~ ^[0-9]+$ ]] && [ ${place} -eq 1 ]; then
    echo "You go first"
else
    echo "I will go first"
    #Make robot move here, and then they will be on same place
fi
free_space_count
