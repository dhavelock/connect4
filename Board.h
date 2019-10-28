#ifndef BOARD_H
#define BOARD_H

#include <vector>

using namespace std;

enum type { RED, BLACK, EMPTY };

class Board {
    private:
        int const NUM = 4;
        int width, height;
        int numMoves;
        int turn;
        vector<vector<int> > board;

    public:
        Board(int,int);
        bool makeMove(int, int);
        bool makeMove(int);
        bool makeRandomMove();
        int getWinner();
        int getWidth();
        int getHeight();
        void printBoard();
};

#endif