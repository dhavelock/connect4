#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <curand.h>
#include <curand_kernel.h>
#include <device_functions.h>

#include "Board.h"
#include "Player.h"

#define BLOCK_COUNT 1
#define THREAD_COUNT 384
#define ROLLOUTS 50
#define NUM 4

using namespace std;

__device__ int getWinner(int boardState[HEIGHT][WIDTH]) {

	// Check Rows
	int numInRow = 0;
	int lastColor = EMPTY;
	for (int i = HEIGHT - 1; i >= 0; i--) {
		for (int j = 0; j < WIDTH; j++) {
			if (boardState[i][j] != EMPTY) {
				if (boardState[i][j] != lastColor) {
					numInRow = 0;
				}
				numInRow++;
				lastColor = boardState[i][j];
				if (numInRow == NUM) {
					return lastColor;
				}
			}
			else {
				numInRow = 0;
				lastColor = boardState[i][j];
			}
		}
		numInRow = 0;
		lastColor = EMPTY;
	}

	// Check Columns
	for (int i = 0; i < WIDTH; i++) {
		for (int j = 0; j < HEIGHT; j++) {
			if (boardState[j][i] != EMPTY && (boardState[j][i] == lastColor || (lastColor != boardState[j][i] && numInRow == 0))) {
				numInRow++;
				lastColor = boardState[j][i];
				if (numInRow == NUM) {
					return lastColor;
				}
			}
			else {
				numInRow = 0;
				lastColor = boardState[j][i];
			}
		}
		numInRow = 0;
		lastColor = EMPTY;
	}

	// Check Diagonal bottom left to top right
	for (int i = NUM - 1; i < WIDTH + HEIGHT - NUM; i++) {
		for (int j = i < HEIGHT ? 0 : i - HEIGHT + 1; j < WIDTH && i - j >= 0; j++) {
			if (boardState[i - j][j] != EMPTY) {
				if (boardState[i - j][j] != lastColor) {
					numInRow = 0;
				}
				numInRow++;
				lastColor = boardState[i - j][j];
				if (numInRow == NUM) {
					return lastColor;
				}
			}
			else {
				numInRow = 0;
				lastColor = boardState[i - j][j];
			}
		}
		numInRow = 0;
		lastColor = EMPTY;
	}

	// Check Diagonal top left to bottom right
	for (int i = NUM - WIDTH; i < HEIGHT - NUM - 1; i++) {
		for (int j = i >= 0 ? 0 : -i; j < WIDTH && i + j < HEIGHT; j++) {
			if (boardState[i + j][j] != EMPTY) {
				if (lastColor != boardState[i + j][j]) {
					numInRow = 0;
				}
				numInRow++;
				lastColor = boardState[i + j][j];
				if (numInRow == NUM) {
					return lastColor;
				}
			}
			else {
				numInRow = 0;
				lastColor = boardState[i + j][j];
			}
		}
		numInRow = 0;
		lastColor = EMPTY;
	}

	return EMPTY;
}

__device__ float generate(curandState* globalState, int ind)
{
	curandState localState = globalState[ind];
	float RANDOM = curand_uniform(&localState);
	globalState[ind] = localState;
	return RANDOM;
}

__global__ void setup_kernel(curandState* state, unsigned long seed)
{
	int id = threadIdx.x;
	curand_init(seed, id, 0, &state[id]);
}

__global__ void simulate(curandState* globalState, int boardState[HEIGHT][WIDTH], int* availableMoves, int *wins, int *totals, int numMoves, int type)
{	
	// Get Tread Id
	int id = blockIdx.x * THREAD_COUNT + threadIdx.x;
	int moveIndex = id % numMoves;

	int boardCopy[HEIGHT][WIDTH];
	for (int i = 0; i < HEIGHT; i++) {
		for (int j = 0; j < WIDTH; j++) {
			boardCopy[i][j] = boardState[i][j];
		}
	}

	int plays = 0;
	int win = 0;

	// Simulate Games
	while(plays < ROLLOUTS) {

		// Create Board Copy
		for (int i = 0; i < HEIGHT; i++) {
			for (int j = 0; j < WIDTH; j++) {
				boardCopy[i][j] = boardState[i][j];
			}
		}

		int number = generate(globalState, id) * 1000000;
		int move = number % numMoves;

		// Make Move
		int success = false;
		for (int i = HEIGHT - 1; i >= 0; i--) {
			if (boardCopy[i][availableMoves[moveIndex]] == EMPTY) {
				boardCopy[i][availableMoves[moveIndex]] = type;
				success = true;
				break;
			}
		}

		if (!success) printf("FAILED TO MAKE MOVE : moveIndex %d : %d\n", moveIndex, availableMoves[moveIndex]);

		// Perform Random Playout
		int winner = getWinner(boardCopy);

		number = generate(globalState, id) * 1000000;
		int moveAvail = true;
		int turn = 1 - type;
		int count = 0;
		while (winner == EMPTY) {

			// Check if game is over
			bool gameover = true;
			for (int i = 0; i < WIDTH; i++) {
				if (boardCopy[0][i] == EMPTY) {
					gameover = false;
					break;
				}
			}
			if (gameover) {
				break;
			}

			// Make random move
			number = generate(globalState, id) * 1000000;
			int randomMove = availableMoves[number % numMoves];
			int randomSuccess = false;
			while (!randomSuccess) {
				randomSuccess = false;
				for (int i = HEIGHT - 1; i >= 0; i--) {
					if (boardCopy[i][randomMove] == EMPTY) {
						boardCopy[i][randomMove] = turn;
						turn = 1 - turn;
						randomSuccess = true;
						break;
					}
				}
				number = generate(globalState, id) * 1000000;
				randomMove = availableMoves[number % numMoves];
			}
			
			winner = getWinner(boardCopy);
		}

		if (getWinner(boardCopy) == type) win++;

		plays++;
	}

	atomicAdd(&(wins[moveIndex]), win);
	atomicAdd(&(totals[moveIndex]), plays);

}

int runSimulation(Board board, int t)
{
	// Create copy of current board state
	vector<vector<int> > boardState = board.getBoardState();
	int boardArr[HEIGHT][WIDTH];
	for (int i = 0; i < HEIGHT; i++) {
		for (int j = 0; j < WIDTH; j++) {
			boardArr[i][j] = boardState[i][j];
		}
	}
	int * boardStateDevice;
	int* availMovesDevice, *wins, *totals;
	int numAvailMoves = board.getLegalMoves().size();

	// Allocate device memory
	cudaMallocManaged((void**)& boardStateDevice, HEIGHT * WIDTH * sizeof(int));
	cudaMallocManaged((void**)& availMovesDevice, numAvailMoves * sizeof(int));
	cudaMallocManaged((void**)& wins, numAvailMoves * sizeof(int));
	cudaMallocManaged((void**)& totals, numAvailMoves * sizeof(int));

	// Copy values to board and availMoves
	std::copy(&boardArr[0][0], &boardArr[0][0] + HEIGHT * WIDTH, boardStateDevice);
	
	for (int i = 0; i < numAvailMoves; i++) {
		availMovesDevice[i] = board.getLegalMoves()[i];
		wins[i] = 0;
		totals[i] = 0;
	}

	// Random Number Generator
	srand(time(0));
	curandState* devStates;
	cudaMalloc(&devStates, numAvailMoves * sizeof(curandState));
	int seed = rand();

	// Start kernel threads
	setup_kernel << <BLOCK_COUNT, THREAD_COUNT >> > (devStates, seed);

	simulate << <BLOCK_COUNT, THREAD_COUNT >> > (devStates, reinterpret_cast<int(*)[WIDTH]>(boardStateDevice), availMovesDevice, wins, totals, numAvailMoves, t);
	
	cudaDeviceSynchronize();

	int move = 0;
	int maxWins = 0;
	int maxTotals = 1;
	for (int i = 0; i < numAvailMoves; i++) {
		printf("%d : %f : %d / %d\n", availMovesDevice[i], (float)wins[i] / (float)totals[i], wins[i], totals[i]);
		if (((float)wins[i] / (float)totals[i]) >= ((float)maxWins / (float)maxTotals)) {
			maxWins = wins[i];
			maxTotals = totals[i];
			move = availMovesDevice[i];
		}
	}

	// Free memory
	cudaFree(wins);
	cudaFree(totals);
	cudaFree(devStates);
	cudaFree(boardStateDevice);
	cudaFree(availMovesDevice);

	printf("Parallel : %d\n", move);

	return move;
}