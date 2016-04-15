#include<stdio.h>
#include<stdlib.h>
#define FOR(i,a,b) for (i = (a); i < (b); i++)
#define N 8
char s[100][100];
int me = 66, op = 87;
int dx[] = {0, 1, 0, -1, 1, 1, -1, -1};
int dy[] = {1, 0, -1, 0, 1, -1, 1, -1};
int out(int x, int y){ return x < 0 || y < 0 || x >= N || y >= N; }
int ok(int x, int y){
	if (s[x][y] != '.') return 0;
	int i,  k;
	FOR(i,0,8){
		FOR(k,1,8){
			int nx = x + dx[i] * k;
			int ny = y + dy[i] * k;
			if (out(nx, ny)) break;
			if (s[nx][ny] == '.') break;
			if (s[nx][ny] == me && k > 1) return 1;
			if (s[nx][ny] == me && k <= 1) break;
			if (s[nx][ny] == op) continue;
		}
	}
	return 0;
}
int main(){
	int i, j;
	while(1){
		scanf("%s", s[0]);
	if (s[0][0] == 'B'){
		scanf("%s", s[0]);
		FOR(i,0,N) scanf("%s", s[i]);
	FOR(i,0,N) FOR(j,0,N){ if (!ok(i, j)) continue; else{
		printf("%d %d\n", i, j);
		fflush(stdout);
	goto EXIT;
	}
	}
	}
	else{
		scanf("%s", s[0]);
		me ^= op;
		op ^= me;
		me ^= op;
		FOR(i,0,N) scanf("%s", s[i]);
	FOR(i,0,N) FOR(j,0,N) if (ok(i, j)){
		printf("%d %d\n", i, j);
		fflush(stdout);
		me ^= op;
		op ^= me;
		me ^= op;
		goto EXIT;
	}
	}
EXIT:
	continue;
	}
	return 0;
}
