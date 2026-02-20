#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
// This program calculates the next best move for a tic tac toe game

// The idea is that by using tic tac toe strategy, we know the middle
// and the corners are the best, so we should got for those first
// and then this means we will go down usually the best move first
// creating a higher alpha allowing us to cut branches quicker
const int best_move_order[9] = {4, 0, 2, 6, 8, 1, 3, 5, 7};

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
    assert((human == 'X' && robot == 'O') || (human == 'O' && robot == 'X'));
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

int minimax(bool is_max, int depth, char board[], char human, 
            char robot, int *nodes_visited, int alpha, int beta) {
    ++(*nodes_visited);
    int score = check_win(board, human, robot);
    // base case:
    if (score == 10) {
        return 10 - depth;
    } 
    if (score == -10) {
        return -10 + depth;
    }
    if (!moves_left(board)) {
        return 0;
    }
    // recursive logic:
    if (is_max) {
        int best = -10;
        for (int i = 0; i < 9; ++i) {
            int move = best_move_order[i];
            if (board[move] != 'O' && board[move] != 'X') {
                int temp = board[move];
                board[move] = robot; // robot is the maximizer
                int val = minimax(!is_max, depth + 1, board, 
                                  human, robot, nodes_visited, alpha, beta);
                if (best < val) {
                    best = val; // the farther depth, the worse
                }
                board[move] = temp; // reset it (since we are on same board)
                // We are on maximizer so it will go for biggest value
                // thus if we find a bigger value, we should go with that 
                // for alpha
                if (best > alpha) {
                    alpha = best;
                }
                // beta is the node above it, if it is the case that 
                // that beta is less than alpha so the minimizer above
                // is already guaranteed a smaller value so we should break 
                // out of the loop since the minimizer wouldn't go down
                // any smaller branches if it was already guaranteed a smaller
                // one on some other path, so no need to keep exploring 
                // down this branch
                // You can think of alpha is exploring the nodes below it
                // if it found a value that is greater than the best value 
                // beta which is above it can do, then obviously beta 
                // would not want to go down that path because the maximizer
                // would just go ahead and choose that value
                // EX: Minimizer     B(5)
                //                  /    \
                //     Maximizer   5      A (where we currently are)
                //                / \    / \
                //               3   5  6   ?
                // We immediately break, and just send up 6, since it doesn't
                // matter what ? is, we are sending it back up to show
                // the path is not appealing for the minimizer to go down
                if (beta <= alpha) {
                    break;
                }
            }
        }
        return best;
    } else { // human's turn which is the minimizer
        int best = 10;
        for (int i = 0; i < 9; ++i) {
            int move = best_move_order[i];
            if (board[move] != 'O' && board[move] != 'X') {
                int temp = board[move];
                board[move] = human; // human is the minimizer
                int val = minimax(!is_max, depth + 1, board, 
                                  human, robot, nodes_visited, alpha, beta);
                if (best > val) {
                    best = val ; // the farther depth, the worse
                }
                board[move] = temp; // reset it (since we are on same board)
                if (best < beta) {
                    beta = best;
                }
                // similar to the other case, if we are on the minimizer
                // right now, we look up and see the node above us which
                // is the maximizer already has alpha guaranteed
                // if we find a beta down our branch that is less than alpha
                // then of course if the maximizer chose us, we would just go
                // with that value, so the maximizer would want the bigger
                // guaranteed value, so all we have to do is to show that this
                // path would be bad for it to go down, so we just return
                // the value we are on.
                if (beta <= alpha) {
                    break;
                }
            }
        }
        return best;
    }
}

int main(int argc, char *argv[]){
    // From our bash script we know we will be give a board that
    //   has at least one empty space
    assert(argc == 11);
    int nodes_visited = 0;
    char robo_char = argv[10][0];
    char human_char = (robo_char == 'X') ? 'O' : 'X';
    char board[9];
    for (int i = 0; i < 9; ++i) {
        board[i] = *argv[i + 1];
    }
    int best_move = 0;
    // initialized to -11 so the best_move can be a valid move
    // as there is a case if alpha stayed -10 then best_move would just stay
    // at zero if all positions returned -10, and then index 0 could be 
    // invalid move.
    int max_score = -11;
    // starting alpha and beta off at their most extreme undesirable values
    // so they will immediately want to become anything closer to their 
    // respective max and min position
    int alpha = -10;
    int beta = 10;
    for (int i = 0; i < 9; ++i) {
        int move = best_move_order[i];
        if (board[move] != 'X' && board[move] != 'O') {
            int temp = board[move];
            board[move] = robo_char;
            int val = minimax(false, 1, board, human_char, robo_char, 
                              &nodes_visited, alpha, beta);
            if (max_score < val) {
                max_score = val;
                best_move = move;
            }
            board[move] = temp;
            // we want to show the minimizer below the node that we are about
            // to each time that we actually already have an alpha, so that
            // if it is able to find a smaller value than we would of course 
            // not go down that (so we are essentially just giving more info)
            if (max_score > alpha) {
                alpha = max_score;
            }
        }
    }
    printf("%d", best_move);
    fprintf(stderr, "%d", nodes_visited);
    return 0;
}

