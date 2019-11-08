CFLAGS = -O -std=c++11
CC = g++
Connect4: Board.o HumanPlayer.o MCTSPlayer.o SearchTree.o main.o
	$(CC) $(CFLAGS) -o Connect4 Board.o HumanPlayer.o MCTSPlayer.o SearchTree.o main.o
Board.o: Board.cpp Board.h
	$(CC) $(CFLAGS) -c Board.cpp
HumanPlayer.o: HumanPlayer.cpp Player.h
	$(CC) $(CFLAGS) -c HumanPlayer.cpp
MCTSPlayer.o: MCTSPlayer.cpp Player.h SearchTree.h
	$(CC) $(CFLAGS) -c MCTSPlayer.cpp
SearchTree.o: SearchTree.cpp SearchTree.h Board.h
	$(CC) $(CFLAGS) -c SearchTree.cpp
main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp
clean:
	rm -f core *.o 