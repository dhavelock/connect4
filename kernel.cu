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

    //HumanPlayer player1 (RED);
	MCTSPlayer player1(RED);
    MCTSParallelPlayer player2 (BLACK);

	while (board.getWinner() == EMPTY) {
		int move;

		if (board.getTurn() == player1.getType()) {
			move = player1.makeMove(board);
		}
		else {
			move = player2.makeMove(board);
		}

		board.makeMove(move);

		board.printBoard();
	}

	//board.printBoard();

	//cout << endl;

	cout << "Winner : " << board.getWinner() << endl;
    
    return 0;
}