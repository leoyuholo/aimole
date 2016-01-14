#include <stdio.h>
 
int main()
{
   int input[9];
   int board[3][3];
   int terminate = 0;
   int round = 0;
NEWROUND:
   while(!terminate){
	int i;
	for (i = 0; i < 9; i++) {
		scanf("%d", &input[i]);
		board[i/3][i%3] = input[i];
	}
	for (i = 0; i < 9; i++) {
		if (input[i] == 1) {
			int x = i/3, y = i%3;
			int j;
			for (j = 0; j < 3; j++) {
				if (board[j][y] == 0) { 
					printf("%d %d\n", j, y);
					goto NEWROUND;
				}
				if (board[x][j] == 0) {
					printf("%d %d\n", x, j);
					goto NEWROUND;
				}	
			} 
		}
	}
	for (i = 0; i < 9; i++) {
		if (input[i] == 0){
			printf("%d %d\n", i/3, i%3);
			goto NEWROUND;
		}
	}
	
   } 
   return 0;
}
