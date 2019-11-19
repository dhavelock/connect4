#ifndef PLAYER_H
#define PLAYER_H

#include "Board.h"
#include "SearchTree.h"

#include <vector>

using namespace std;

class Player {
    protected:
        int type;
    public:
        Player(int t) { type = t; };
        int getType() { return type; };
        virtual int makeMove(Board board) { return EMPTY; };   // make move on board
};

class HumanPlayer: public Player {
    public:
        using Player::Player;
        int makeMove(Board board);   // make move on board
};

class MCTSPlayer: public Player {
    private:
        SearchTree* st = NULL;
        int timeout = 100000;
    public:
        using Player::Player;
        int makeMove(Board board);
};

#endif