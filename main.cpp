#include <iostream>
#include "Board.h"

using namespace std;

int main () {
    Board board (7, 6);

    board.printBoard();

    cout << endl;

    while (board.getWinner() == EMPTY) {
        board.makeRandomMove();
    }

    board.printBoard();

    cout << endl;

    cout << "Winner : " << board.getWinner() << endl;
    
    return 0;
}