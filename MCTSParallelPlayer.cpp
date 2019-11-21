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

int MCTSParallelPlayer::makeMove(Board board) {
	// Simple way...
	int move = runSimulation(board, type);

	return move;
}