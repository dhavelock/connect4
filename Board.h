#ifndef BOARD_H
#define BOARD_H

#define HEIGHT 6
#define WIDTH 7

#define NUM_ROW 4

#include <vector>

using namespace std;

enum type { RED, BLACK, EMPTY };

class Board {
    private:
        int NUM = NUM_ROW;
        int width, height;
        int numMoves;
        int turn;

    public:
        Board(int,int);
        bool makeMove(int, int);
        bool makeMove(int);
        bool makeRandomMove();
        int getWinner();
        int getWidth();
        int getHeight();
        int getTurn();
        Board* clone();
        vector<int> getLegalMoves();
        vector<vector<int> >& getBoardState() { return board; };
        void printBoard();

		vector<vector<int> > board;
};

#endif