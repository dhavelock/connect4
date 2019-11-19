#ifndef SEARCH_TREE_H
#define SEARCH_TREE_H

#include "Board.h"
#include <vector>

class SearchTree {
    private:
        Board* board = NULL;
        SearchTree* parent = NULL;
        vector< SearchTree* > children;
        int wins = 0;
        int plays = 0;
    public:
        SearchTree(Board b, SearchTree* p);
        int expand();
        int select();
        int simulate(int type);
        void backpropagate(int win);
        int getWins() { return wins; };
        int getPlays() { return plays; };
};

#endif