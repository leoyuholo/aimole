#include <stdio.h>
/*
strategy:
1. If it is the first round, and the middle tile hasn't been occupied, choose it.
2. If it is not the first round, weight each tile of the board by following rules:
	(1) If the blank tile is near to any tile belong to us, add 1 credit.
	(2) If our opponent is going to win by getting the blank tile, add 5 credits.
	(3) If we will win by getting the blank tile, add 20 credits. 
3. Choose the tile with most credits 
 */ 
int main() {
	int board[3][3];
	int weight[3][3];
	int round1 = 1;
	while(1) {
		int x, y, hasBlankTile = 0;
		//get board state and initialize board weight
		for (x = 0; x < 3; x++) {
			for (y = 0; y < 3; y++) {
				scanf("%d", &board[x][y]);
				weight[x][y] = 0;
				if (board[x][y] == 0) hasBlankTile = 1;
			}
		}
		if (!hasBlankTile) return 0;
		if (round1 && board[1][1] == 0) {
			printf("%d %d\n", 1, 1);
		}
		else {
			//(1) If the blank tile is near to any tile belong to us, add 1 credit.
			for (x = 0; x < 3; x++) {
				for (y = 0; y < 3; y++) {
					if (board[x][y] == 0
						&& x - 1 >= 0
						&& board[x - 1][y] == 1) {
						weight[x][y]++;
					}
					else if (board[x][y] == 0
							&& x + 1 < 3
							&& board[x + 1][y] == 1) {
						weight[x][y]++;
					}
					else if (board[x][y] == 0
							&& y - 1 >= 0
							&& board[x][y - 1] == 1) {
						weight[x][y]++;
					}
					else if (board[x][y] == 0
							&& y + 1 < 2
							&& board[x][y + 1] == 1) {
						weight[x][y + 1]++;
					}
				}
			}
			//(2) If our opponent is going to win by getting the blank tile, add 5 credits.
			int i, j; 
			for (i = 0; i < 3; i++) {
				int row = 0, col = 0;
				for (j = 0; j < 3; j++) {
					if (board[i][j] == 2) row++;
					if (board[j][i] == 2) col++;
				}
				if (row == 2) {
					for (j = 0; j < 3; j++) {
						if (board[i][j] == 0) weight[i][j] += 5;
					}
				}
				if (col == 2) {
					for (j = 0; j < 3; j++) {
						if (board[j][i] == 0) weight[j][i] += 5;
					}
				}
			}
			int diagonal1 = 0, diagonal2 = 0;
			for (i = 0; i < 3; i++) {
				if (board[i][i] == 2) diagonal1++;
				if (board[i][2 - i] == 2) diagonal2++;
			}
			if (diagonal1 == 2) {
				for (i = 0; i < 3; i++) {
					if (board[i][i] == 0) weight[i][i] += 5;
				}
			}
			if (diagonal2 == 2) {
				for (i = 0; i < 3; i++) {
					if (board[i][2 - i] == 0) weight[i][2 - i] += 5;
				}
			}
			//(3) If we will win by getting the blank tile, add 10 credits.
                        for (i = 0; i < 3; i++) {
                                int row = 0, col = 0;
                                for (j = 0; j < 3; j++) {
                                        if (board[i][j] == 1) row++;
                                        if (board[j][i] == 1) col++;
                                }
                                if (row == 2) {
                                        for (j = 0; j < 3; j++) {
                                                if (board[i][j] == 0) weight[i][j] += 20;
                                        }
                                }
                                if (col == 2) {
                                        for (j = 0; j < 3; j++) {
                                                if (board[j][i] == 0) weight[j][i] += 20;
                                        }
                                }
                        }
                        for (i = 0; i < 3; i++) {
                                if (board[i][i] == 1) diagonal1++;
                                if (board[i][2 - i] == 1) diagonal2++;
                        }
                        if (diagonal1 == 2) {
                                for (i = 0; i < 3; i++) {
                                        if (board[i][i] == 0) weight[i][i] += 20;
                                }
                        }
                        if (diagonal2 == 2) {
                                for (i = 0; i < 3; i++) {
                                        if (board[i][2 - i] == 0) weight[i][2 - i] += 20;
                                }
                        }
			//Choose the tile with most credits
			int max = 0, ansx, ansy;
			for (x = 0; x < 3; x++) {
				for (y = 0; y < 3; y++) {
					if (weight[x][y] > max)	{
						max = weight[x][y];
						ansx = x;
						ansy = y;
					}
				}
			}
			printf("%d %d\n", ansx, ansy);
		}
		round1 = 0;	
	}
	return 0;
}
