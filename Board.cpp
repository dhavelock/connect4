#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

#include "Board.h"

using namespace std;

Board::Board (int w, int h) {
    width = w;
    height = h;
    turn = RED; // RED always begins
    numMoves = 0; 
    board = vector<vector<int> >(height, vector<int> (width, EMPTY));

    srand((unsigned)time(0)); 
}

int Board::getTurn() { return turn; }

Board* Board::clone() {
    static Board newBoard (width, height);
    newBoard.turn = turn;
    newBoard.numMoves = numMoves;
    
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            newBoard.board[i][j] = board[i][j];
        }
    }

    return &newBoard;
}

vector<int> Board::getLegalMoves() {
    vector<int> moves;
    for (int i = 0; i < width; i++) {
        if (board[0][i] == EMPTY) {
            moves.push_back(i);
        }
    }
    return moves;
}

/*
 * Returns true of move was made successfully, false otherwise
 */
bool Board::makeMove(int col, int type) {
    for (int i = height-1; i >= 0; i--) {
        if (board[i][col] == EMPTY) {
            board[i][col] = type;
            numMoves++;
            return true;
        }
    }
    return false;
}

bool Board::makeMove(int col) {
    for (int i = height-1; i >= 0; i--) {
        if (board[i][col] == EMPTY) {
            board[i][col] = turn;
            turn = 1 - turn;
            numMoves++;
            return true;
        }
    }
    return false;
}

bool Board::makeRandomMove() {
    while (!makeMove(rand() % width)) ;

    return numMoves != height * width;
}

/*
 * Returns 2 if no winner, 0 if RED wins, 1 if BLACK wins
 */
int Board::getWinner() {

    // Check Rows
    int numInRow = 0;
    int lastColor = EMPTY;
    for (int i = height-1; i >= 0; i--) {
        for (int j = 0; j < width; j++) {
            if (board[i][j] != EMPTY) {
                if (board[i][j] != lastColor) {
                    numInRow = 0;
                }
                numInRow++;
                lastColor = board[i][j];
                if (numInRow == NUM) {
                    return lastColor;
                }
            } else {
                numInRow = 0;
                lastColor = board[i][j];
            }
        }
        numInRow = 0;
        lastColor = EMPTY;
    }

    // Check Columns
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (board[j][i] != EMPTY && (board[j][i] == lastColor || (lastColor != board[j][i] && numInRow == 0))) {
                numInRow++;
                lastColor = board[j][i];
                if (numInRow == NUM) {
                    return lastColor;
                }
            } else {
                numInRow = 0;
                lastColor = board[j][i];
            }
        }
        numInRow = 0;
        lastColor = EMPTY;
    }

    // Check Diagonal bottom left to top right
    for (int i = NUM-1; i < width+height-NUM; i++) {        
        for (int j = i < height ? 0 : i-height+1; j < width && i-j >= 0; j++) {
            if (board[i-j][j] != EMPTY) {
                if (board[i-j][j] != lastColor) {
                    numInRow = 0;
                }
                numInRow++;
                lastColor = board[i-j][j];
                if (numInRow == NUM) {
                    return lastColor;
                }
            } else {
                numInRow = 0;
                lastColor = board[i-j][j];
            }
        }
        numInRow = 0;
        lastColor = EMPTY;
    }

    // Check Diagonal top left to bottom right
    for (int i = NUM-width; i < height-NUM-1; i++) {
        for (int j = i >= 0 ? 0 : -i; j < width && i+j < height; j++) {
            if (board[i+j][j] != EMPTY) {
                if (lastColor != board[i+j][j]) {
                    numInRow = 0;
                }
                numInRow++;
                lastColor = board[i+j][j];
                if (numInRow == NUM) {
                    return lastColor;
                }
            } else {
                numInRow = 0;
                lastColor = board[i+j][j];
            }
        }
        numInRow = 0;
        lastColor = EMPTY;
    }

    return EMPTY;
}

int Board::getWidth() {
    return width;
}

int Board::getHeight() {
    return height;
}

void Board::printBoard() {
    for (vector<int> row : board) {
        for (int val : row) {
            if (val == EMPTY) {
                cout << ". ";;
            } else {
                cout << val << " ";
            }
        }
        cout << endl;
    }
}