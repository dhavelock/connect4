#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <vector>
#include <iostream>
#include <ctime>

#include <stdio.h>

#include "Player.h"
#include "Board.h"

extern int runSimulation(Board board, int t);

using namespace std;

int simulate(Board board, int move, int t) {
	Board* b = board.clone();

	b->makeMove(move);

	while (b->getWinner() == EMPTY && b->makeRandomMove());

	int win = 0;

	if (b->getWinner() == t) win++;

	return win;
}

int MCTSPlayer::makeMove(Board board, double duration) {
    // Simple way...
    vector<int> availableMoves = board.getLegalMoves();
    int move = 0;
    int maxWins = 0;
    int maxPlays = 1;
	int numAvailMoves = availableMoves.size();

	if (duration == 0) duration = 1;

    for (int i = 0; i < numAvailMoves; i++) {
        clock_t start = clock();
        int wins = 0;
        int plays = 0;
		
        while ((double)(clock() - start) / CLOCKS_PER_SEC < (double)(duration / (float)numAvailMoves)) {
            wins += simulate(board, availableMoves[i], type);
            plays++;
        }

        cout << availableMoves[i] << " : " << (float)wins / (float)plays << " : " << (float)wins << " / " << (float)plays << endl;

        if ((float)wins/(float)plays >= (float)maxWins/(float)maxPlays) {
            maxWins = wins;
            maxPlays = plays;
            move = availableMoves[i];
        }
    }

	printf("Sequential : %d\n", move);
	
    return move;
}