#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <iostream>

#include "Board.h"
#include "Player.h"

#define BLOCK_COUNT 1
#define THREAD_COUNT 1

using namespace std;

int main () {
	
    Board board (WIDTH, HEIGHT);

    HumanPlayer player1 (RED);
    MCTSPlayer player2 (BLACK);

    while (board.getWinner() == EMPTY) {
        board.printBoard();

        int move;

        if (board.getTurn() == player1.getType()) {
            cout << endl;
            move = player1.makeMove(board);
            cout << endl;
        } else {
            cout << endl;
            move = player2.makeMove(board);
            cout << endl;
        }

        board.makeMove(move);
    }

    board.printBoard();

    cout << endl;

    cout << "Winner : " << board.getWinner() << endl;
    
    return 0;
}