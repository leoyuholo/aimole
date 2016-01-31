#include <stdio.h>
#include <stdlib.h>
#include <time.h>
/*
strategy: Radomly select a tile, if it is blank choose it.
Otherwise, select again.
 */
int main() {
	srand(time(NULL));
	int terminate = 0;
	int board[3][3];

	while (!terminate) {
		//get board state
		int x, y, hasBlankTile = 0;
		for (x = 0; x < 3; x++) {
			for (y = 0; y < 3; y++) {
				scanf("%d", &board[x][y]);
				if (board[x][y] == 0) hasBlankTile = 1;
			}
		}
		if (!hasBlankTile) terminate = 1;
		while (hasBlankTile) {
			int selectX = rand() % 3, selectY = rand() % 3;
			if (board[selectX][selectY] == 0) {
				printf("%d %d\n", selectX, selectY);
				break;
			}
		}
	}
	return 0;
}
