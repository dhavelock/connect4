#include <vector>
#include <iostream>
#include <ctime>

#include "Player.h"
#include "Board.h"

using namespace std;

int simulate(Board board, int move, int t) {
    Board* b = board.clone();

    b->makeMove(move);

    while (b->getWinner() == EMPTY && b->makeRandomMove()) ;

    int win = 0;

    if (b->getWinner() == t) win++;

    return win;
}

int MCTSPlayer::makeMove(Board board) {
    // Simple way...
    vector<int> availableMoves = board.getLegalMoves();
    int move = 0;
    int maxWins = 0;
    int maxPlays = 1;
    for (int i = 0; i < availableMoves.size(); i++) {
        clock_t start = clock();
        int wins = 0;
        int plays = 0;
        while (clock() - start < timeout) {
            wins += simulate(board, availableMoves[i], type);
            plays++;
        }

        cout << availableMoves[i] << " : " << (float)wins/(float)plays << endl;

        if ((float)wins/(float)plays > (float)maxWins/(float)maxPlays) {
            maxWins = wins;
            maxPlays = plays;
            move = i;
        }
    }
    cout << endl;

    return availableMoves[move];
}