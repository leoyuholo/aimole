
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

int is_command_valid(char command[], int game_board[][4]);

int main() {
    int board[4][4];
    int x, y;
    int terminate = 0;
    while (!terminate) {
        for (x = 0; x < 4; x++) {
            for (y = 0; y < 4; y++) {
                scanf("%d", &board[x][y]);
            }
        }
        int triedUp = 0, triedDown = 0, triedLeft = 0, triedRight = 0;
        //srand(time(NULL));
        srand(2030);
        while (!triedUp || !triedDown || !triedLeft || !triedRight) {
            int move = rand() % 4;
            if (move == 0 && !triedUp) {
                if (is_command_valid("UP", board) == 1) {
                    printf("UP\n");
                    break;
                }
                else {
                    triedUp = 1;
                }
            }
            else if (move == 1 && !triedDown) {
                if (is_command_valid("DOWN", board) == 1) {
                    printf("DOWN\n");
                    break;
                }
                else {
                    triedDown = 1;
                }
            }
            else if (move == 2 && !triedLeft) {
                if (is_command_valid("LEFT", board) == 1) {
                    printf("LEFT\n");
                    break;
                }
                else {
                    triedLeft = 1;
                }
            }
            else if (move == 3 && !triedRight) {
                if (is_command_valid("RIGHT", board) == 1) {
                    printf("RIGHT\n");
                    break;
                }
                else {
                    triedRight = 1;
                }
            }
        }
        if (triedUp && triedDown && triedLeft && triedRight) terminate = 1;
    }
    return 0;
}


int is_command_valid(char command[], int game_board[][4]){
    int x, y;
    if (strcmp(command, "UP") == 0) {
        for(y = 0; y < 4; y++){
            for(x = 0; x < 3; x++){
                if(game_board[x][y] == game_board[x + 1][y] && game_board[x][y]!=0){
                    return 1;
                }
                if(game_board[x][y] == 0 && game_board[x + 1][y] != 0){
                    return 1;
                }
            }
        }
    }
    else if (strcmp(command, "DOWN") == 0) {
        for(y = 0; y < 4; y++){
            for(x = 3; x > 0; x--){
                if(game_board[x][y] == game_board[x - 1][y] && game_board[x][y]!=0){
                    return 1;
                }
                if(game_board[x][y] == 0 && game_board[x - 1][y] != 0){
                    return 1;
                }
            }
        }
    }
    else if (strcmp(command, "LEFT") == 0) {
        for(x = 0; x < 4; x++){
            for(y = 0; y < 3; y++){
                if(game_board[x][y] == game_board[x][y + 1] && game_board[x][y]!=0){
                    return 1;
                }
                if(game_board[x][y] == 0 && game_board[x][y + 1] != 0){
                    return 1;
                }
            }
        }
    }
    else if (strcmp(command, "RIGHT") == 0) {
        for(x = 0; x < 4; x++){
            for(y = 3; y > 0; y--){
                if(game_board[x][y] == game_board[x][y - 1] && game_board[x][y] != 0){
                    return 1;
                }
                if(game_board[x][y] == 0 && game_board[x][y - 1] != 0){
                    return 1;
                }
            }
        }
    }
    return 0;
}