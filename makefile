CFLAGS = -O -std=c++11
CC = g++
Connect4: Board.o main.o
	$(CC) $(CFLAGS) -o Connect4 Board.o main.o
Board.o: Board.cpp
	$(CC) $(CFLAGS) -c Board.cpp
main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp
clean:
	rm -f core *.o 