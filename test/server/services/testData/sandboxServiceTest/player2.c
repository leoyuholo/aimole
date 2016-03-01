
#include<stdio.h>
#include<stdlib.h>

static char checkaccess(char map[8][8],int a,int b);




static int checkpos(char map[8][8],char c,char d,int a,int b)
{ int dir;int t=0;
        int dx[8]={-1,-1,-1, 0, 0, 1, 1, 1};
        int dy[8]={-1, 0, 1,-1, 1,-1, 0, 1};

        for(dir=0;dir<8;dir++)
        {
                if(checkaccess(map,a+dx[dir],b+dy[dir])==d)
                {
                        int curr=a; int curc=b;


                        while(checkaccess(map,curr+dx[dir],curc+dy[dir])==d)
                        {
                                curr+=dx[dir];
                                curc+=dy[dir];

                        }

                        if(checkaccess(map,curr+dx[dir],curc+dy[dir])==c)
                        {
                                t++;


                        }

                }


        }
        return t;
}
void computer_1155068110(char map[8][8],char turn,char nextturn,int *row,int *column)
{int i,j;

        while(1)
        { for(i=0;i<8;i++)
                {
                        for(j=0;j<8;j++)

                        {
                                if((map[i][j]==' ')&&(checkpos(map,turn,nextturn,i,j)>0))
                                {
                                        if(rand()%2==0)
                                        {
                                                *row=i;
                                                *column=j;
                                                return;

                                        }

                                }

                        }


               }
         }


 }

static char checkaccess(char map[8][8], int a, int b)
{
        if(a>7||b>7||a<0||b<0)
        { return '*';
        }

        else
                return map[a][b];
}

int main(){
        char map[8][8], s[100];
        char me[10], op[10];
        while(scanf("%s%s", me, op) == 2){
                int i, j;
                for (i = 0; i < 8; i++){
                        scanf("%s", s);
                        for (j = 0; j < 8; j++)
                                map[i][j] = s[j] == 'B' ? '@' : (s[j] == 'W' ? 'O' : ' ');
                }
                me[0] = me[0] == 'B' ? '@' : 'O';
                op[0] = op[0] == 'B' ? '@' : 'O';
                int row, col;
                computer_1155068110(map, me[0], op[0], &row, &col);
                printf("%d %d\n", row, col);
        }
        return 0;
}