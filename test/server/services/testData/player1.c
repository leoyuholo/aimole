#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    int n = 0;
    srand(time(NULL));
    while(1) {
        scanf("%d", &n);
        // usleep(rand() % 600000 + 300000);
        printf("%d\n", n + 1);
    }
    return 0;
}
