#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <iostream>
#include <ctime>

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

	double duration = 0;

	while (board.getWinner() == EMPTY) {
		int move;

		if (board.getTurn() == player1.getType()) {
			clock_t start = clock();
			move = player1.makeMove(board, duration);
			printf("Seq Time : %.2fs\n", (double)(clock() - start) / CLOCKS_PER_SEC);
		}
		else {
			clock_t start = clock();
			move = player2.makeMove(board);
			duration = (double)(clock() - start) / CLOCKS_PER_SEC;
			printf("Par Time : %.2fs\n", duration);
		}

		board.makeMove(move);

		board.printBoard();
	}

	board.printBoard();

	cout << "Winner : " << board.getWinner() << endl;

    
    return 0;
}