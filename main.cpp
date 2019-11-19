#include <iostream>
#include "Board.h"
#include "Player.h"

using namespace std;

int main () {
    Board board (7, 6);

    HumanPlayer player1 (RED);
    MCTSPlayer player2 (BLACK);

    while (board.getWinner() == EMPTY) {
        board.printBoard();

        int move;

        if (board.getTurn() == player1.getType()) {
            cout << endl;
            move = player1.makeMove(board);
            cout << endl;
        } else {
            cout << endl;
            move = player2.makeMove(board);
            cout << endl;
        }

        board.makeMove(move);
    }

    board.printBoard();

    cout << endl;

    cout << "Winner : " << board.getWinner() << endl;
    
    return 0;
}