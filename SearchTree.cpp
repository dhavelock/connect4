#include <iostream>
#include <vector>
#include "SearchTree.h"
#include "Board.h"

using namespace std;

SearchTree::SearchTree(Board b, SearchTree* p) {
    board = b.clone();
    wins = 0;
    plays = 0;
    parent = p;
}

int SearchTree::expand() {
    return 0;
}

int SearchTree::select() {
    return 0;
}

int SearchTree::simulate(int t) {
    return 0;
}


void SearchTree::backpropagate(int win) {

}