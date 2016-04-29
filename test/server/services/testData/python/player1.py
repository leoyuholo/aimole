import sys
import json
class Verdict:
    def __init__(self):
        self.EMPTY = -1
        self.BLACK = 1
        self.WHITE = 0
        self.board = [[self.EMPTY for i in range(8)] for j in range(8)]
        self.board[3][3] = self.BLACK
        self.board[3][4] = self.WHITE
        self.board[4][3] = self.WHITE
        self.board[4][4] = self.BLACK
        self.turn = 0
        self.winner = -1
        self.score = [2, 2]
        self.dx = [0, 1, 0, -1, 1, 1, -1, -1]
        self.dy = [1, 0, -1, 0, 1, -1, 1, -1]
        self.display = {}


    def update(self, player, x, y, trial):
        if not trial:
            self.board[x][y] = player
            self.score[player] += 1
        for d in range(8):
            num = 0
            for l in range(1, 8):
                nx, ny = x + l * self.dx[d], y + l * self.dy[d]
                if (not self.inside(nx, ny)) or self.board[nx][ny] == self.EMPTY:
                    break
                elif self.board[nx][ny] == 1 - player:
                    num -= 1
                elif self.board[nx][ny] == player:
                    num *= -1
                    break
            if num <= 0:
                continue
            if trial:
                return True
            self.score[player] += num
            self.score[1 - player] -= num
            for l in range(1, 8):
                nx, ny = x + l * self.dx[d], y + l * self.dy[d]
                if self.board[nx][ny] == 1 - player:
                    self.board[nx][ny] = player
                else:
                    break
        return False

    def inside(self, x, y):
        return 0 <= x < 8 and 0 <= y < 8

    def valid_move(self, player, x, y):
        if (not self.inside(x, y)) or self.board[x][y] != self.EMPTY:
            return False
        if self.update(player, x, y, True):
            return True
        return False

    def main(self):
        while True:
            s = sys.stdin.readline()
            if len(s) == 0:
                return
            player =  self.BLACK if s[0] == 'B' else self.WHITE
            #self.board = [[{ 'B' : self.BLACK, 'W' : self.WHITE , '.' : self.EMPTY }[_] for _ in sys.stdin.readline()]for i in range(8)]
            for i in range(8):
                s = sys.stdin.readline()
                for j in range(8):
                    if s[j] == 'B':
                        self.board[i][j] = self.BLACK
                    elif s[j] == 'W':
                        self.board[i][j] = self.WHITE
                    elif s[j] == '.':
                        self.board[i][j] = self.EMPTY

            #self.board = [[{ 'B' : self.BLACK, 'W' : self.WHITE , '.' : self.EMPTY }[_] for _ in sys.stdin.readline()]for i in range(8)]

            ok = 0
            for i in range(8):
                for j in range(8):
                    if self.valid_move(player, i, j):
                        print('%d %d' % (i, j))
                        ok = 1
                        break
                if ok:
                    break

if __name__ == '__main__':
    verdict = Verdict()
    verdict.main()