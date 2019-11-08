#include <vector>
#include <iostream>

#include "Player.h"
#include "Board.h"

using namespace std;

int HumanPlayer::makeMove(Board board) {
    int move;
    cout << type << " : ";
    cin >> move;
    return move;
}