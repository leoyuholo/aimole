#include <stdio.h>
#include <time.h>
#include <stdlib.h>

int main() {
    int n = 0;
    srand(time(NULL));
    while(1) {
        scanf("%d", &n);
        printf("%d\n", n * 2);
    }
    return 0;
}
