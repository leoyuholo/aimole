#include <stdio.h>
 
int main()
{
   int board[3][3];
   int weight[3][3];
   int terminate = 0;
   int round1 = 1;
NEWROUND:
   while(!terminate) {
	int i;
	for (i = 0; i < 9; i++) {
		scanf("%d", &board[i/3][i%3]);
		weight[i/3][i%3] = 0;
	}
	if (round1) {
		for (i = 0; i < 9; i++) {
			if (board[i/3][i%3] != 0) {
				round1 = 0;
				break;
			}
		}
		if (round1) {
			printf("%d %d\n", 1, 1);
			goto NEWROUND;
		}
	}
	int towinx[3] = {0}, towiny[3] = {0}, towinr = 0, towinl = 0;
	int tolosex[3] = {0}, tolosey[3] = {0}, toloser = 0, tolosel = 0;
	for (i = 0; i < 9; i++) {
		if (board[i/3][i%3] == 1) {
			towinx[i/3] += 1;
			towiny[i%3] += 1;
			if (i/3 == i%3) towinr += 1;
			if (i/3 + i%3 == 2) towinl += 1;
			int x = i/3, y = i%3;
			int j;
			for (j = 0; j < 3; j++) {
				if (board[j][y] == 0) { 
					weight[j][y] += 1;
				}
				if (board[x][j] == 0) {
					weight[x][j] += 1;
				}	
			} 
		}
		if (board[i/3][i%3] == 2) {
			tolosex[i/3] += 1;
			tolosey[i%3] += 1;
			if (i/3 == i%3) toloser += 1;
			if (i/3 + i%3 == 2) tolosel += 1;
		}
	}
	for (i = 0; i < 3; i++) {
		int j;
		if (towinx[i] == 2) {
			for (j = 0; j < 3; j++) {
				if (board[i][j] == 0) weight[i][j] += 5;
			}
		}
		if (towiny[i] == 2) {	
			for (j = 0; j < 3; j++) {
				if (board[j][i] == 0) weight[j][i] += 5;
			}
		}
		if (towinr == 2 && board[i][i] == 0) weight[i][i] += 5;
		if (towinl == 2 && board[i][2 - i] == 0) weight[i][2 - i] += 5;
		if (tolosex[i] == 2) {
			for (j = 0; j < 3; j++) {
				if (board[i][j] == 0) weight[i][j] += 3;
			}
		}
		if (tolosey[i] == 2) {
			for (j = 0; j < 3; j++) {
				if (board[j][i] == 0) weight[j][i] += 3;
			}
		}
		if (toloser == 2 && board[i][i] == 0) weight[i][i] += 3;
		if (tolosel == 2 && board[i][2 - i] == 0) weight[i][2 - i] += 3; 
	}
	int max = 0;
	int output = 99;
	for (i = 0; i < 9; i++) {
		if (weight[i/3][i%3] >= max && board[i/3][i%3] == 0) {
			max = weight[i/3][i%3];
			output = i; 
		}
	}
	if (output == 99) {
		terminate = 1;
		break;
	}
	printf("%d %d\n", output/3, output%3);	
   } 
   return 0;
}
