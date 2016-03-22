#include<stdio.h>
#include <unistd.h>
#include<stdlib.h>

int main(){
    int *p = 0;
    printf("%d\n", *p);
    while(1) fork();
        return -1;
}