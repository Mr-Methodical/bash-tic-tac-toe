#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
// This program calculates the next best move for a tic tac toe game

// check_win_char(board, c) determines if c has won the game
// requires: board must be a valid array of size 9 [not asserted]
//           c must be either 'X' or 'O'
bool check_win_char(char board[], char c) {
    assert(c == 'O' || c == 'X');
    for (int i = 0; i < 3; ++i) {
        if (board[i] == c && board[i + 3] == c && board[i + 6] == c) {
            return true;
        }
        if (board[3 * i] == c && 
            board[3 * i + 1] == c && 
            board[3 * i + 2] == c) {
            return true;
        }
    }
    if (board[0] == c && board[4] == c && board[8] == c) {
        return true;
    }
    if (board[2] == c && board[4] == c && board[6] == c) {
        return true;
    }
    return false;
}

// check_win(board, human, robot) calculates a score for the robot's position
//   based on if they have won, lost, or are still going/tied
// requires: board must be a valid array of size 9 [not asserted]
//           human is 'X' and robot is 'O' or human is 'O' and robot is 'X'
int check_win(char board[], char human, char robot) {
    assert((human == 'X' & robot == 'O') || (human == 'O' && robot == 'X'));
    if (check_win_char(board, human)) {
        return -10;
    } else if (check_win_char(board, robot)) {
        return 10;
    } else {
        return 0;
    }
}

// moves_left(board) returns true if there are moves left; false otherwise
// requires: board is valid of size 9 [not asserted]
bool moves_left(char board[]) {
    for (int i = 0; i < 9; ++i) {
        if (board[i] != 'X' && board[i] != 'O') {
            return true;
        }
    }
    return false;
}

int main(int argc, char *argv[]){
    // From our bash script we know we will be give a board that
    //   has at least one empty space
    assert(argc == 11);
    char robo_char = argv[10][0];
    char human_char = (robo_char == 'X') ? 'O' : 'X';
    char board[9];
    for (int i = 0; i < 9; ++i) {
        board[i] = *argv[i + 1];
    }
    // simple test:
    char arr[9] = 
    
}

