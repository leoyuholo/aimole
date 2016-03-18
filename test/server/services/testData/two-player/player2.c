// by Janice Chen (https://github.com/jjanicechen)
#include <stdio.h>
/*
strategy: Loop through all the tiles.
Whenever encounter a tile belong to ourselves, 
find a blank tile next to it and return.
If failed, find any one blank tile and return.
 */ 
int main() {
	int board[3][3];
	int terminate = 0;
	while(!terminate) {
		//get board state
		int x, y;
		for (x = 0; x < 3; x++) {
			for (y = 0; y < 3; y++) {
				scanf("%d", &board[x][y]);
			}
		}
		//find a blank tile next to our tile
		int find = 0;
		for (x = 0; x < 3; x++) {
			for (y = 0; y < 3; y++) {
				if (board[x][y] == 1) {
					if (x - 1 >= 0
							&& board[x - 1][y] == 0) {
						printf("%d %d\n", x - 1, y);
						find = 1;
						break;
					}
					else if (x + 1 < 3
							&& board[x + 1][y] == 0) {
						printf("%d %d\n", x + 1, y);
						find = 1;
						break;
					}
					else if (x - 1 >= 0
							&& board[x][y - 1] == 0) {
						printf("%d %d\n", x, y - 1);
						find = 1;
						break;
					}
					else if (x + 1 < 3
							&& board[x][y + 1] == 0) {
						printf("%d %d\n", x, y + 1);
						find = 1;
						break;
					}
				}
			}
			if (find) break;
		}
		if (!find) {
			//find any blank file. If there is no blank tile, terminate.
			int hasBlankTile = 0, i;
			for (i = 0; i < 9; i++) {
				if (board[i/3][i%3] == 0) {
					hasBlankTile = 1;
					printf("%d %d\n", i/3, i%3);
					break;
				}
			}
			if (!hasBlankTile) {
				terminate = 1;
			}
		}
	}
	return 0;
}
