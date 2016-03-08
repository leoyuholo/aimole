
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

    def send_action(self, action):
#        self.log.write(json.dumps(action) + '\n')
        print(json.dumps(action))

    def report_error(self, error_message):
        return
        action = {
                    'action' : 'error',
                    'errorMessage' : error_message
                }
        self.send_action(action)

    def report_winner(self):
        if self.winner == -1:
            if self.score[0] == self.score[1]:
                self.winner = 2
            else:
                self.winner = 1 if self.score[1] > self.score[0] else 0
        board = [[x + 1 for x in row] for row in self.board]

        display = {
                    'board' : board,
                    'message' : 'draw' if self.winner == 2 else 'winner is %d' % (self.winner + 1)
                  }

        action = {
                    'action' : 'stop',
                    'winner' : self.winner,
                    'score' : self.score,
                    'display' : display,
                 }

        mp = {
                self.EMPTY : '.',
                self.BLACK : 'B',
                self.WHITE : 'W'
             }
#        message = '\n'.join([''.join([mp[_] for _ in row]) for row in self.board]) + '\n'
#        self.log.write(message)
#        print(message)

        self.send_action(action)

    def query_command(self):
        json_string = raw_input()
        command = json.loads(json_string)
#        self.log.write(json_string + '\n')
        return command

    def query_player(self, player):
        mp = {
                self.EMPTY : '.',
                self.BLACK : 'B',
                self.WHITE : 'W'
             }
        player_input = mp[player] + ' ' + mp[1 - player] + '\n'
        player_input += '\n'.join([''.join([mp[_] for _ in row]) for row in self.board]) + '\n'
 #       self.log.write(message)
        board = [[x + 1 for x in row] for row in self.board]

        display = {
                    'board' : board
 #                   'message' : ''
                  }

        action = {
                    'action' : 'next',
                    'nextPlayer' : player,
                    'writeMsg' : player_input,
                    'display' : display
                 }

        self.send_action(action)
#        print(message)
        return self.query_command()

    #return next player, return -1 if both can't move
    def next_player(self):
        player = 1 - self.turn
        for i in range(8):
            for j in range(8):
                if self.valid_move(player, i, j):
                    return player

        player = self.turn
        for i in range(8):
            for j in range(8):
                if self.valid_move(player, i, j):
                    return player

        return -1

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

    def prt(self):
        return
        mp = { self.EMPTY : ' ', self.BLACK : '@', self.WHITE : 'O' }
        self.out = open('out', 'a')
        self.out.write('    0   1   2   3   4   5   6   7 \n')
        self.out.write('  +---+---+---+---+---+---+---+---+\n')
        for i in range(8):
            a = [ mp[_] for _ in self.board[i] ]
            self.out.write('%d | ' % i + ' | '.join(a) + ' |' + '\n')
            self.out.write('  +---+---+---+---+---+---+---+---+\n')
        self.out.write('\nPlayer O: %d\t\tPlayer @: %d\t\t\n\n' % (self.score[0], self.score[1]))
        if (self.winner == -1):
            self.out.write('Current Turn:  %s\n' % mp[self.turn])
            self.out.write('Row: [0-7]: Column: [0-7]: ')
        elif self.winner == 2:
            self.out.write('Draw game!\n')
        else:
            self.out.write('Winner: Player %s!\n' % mp[self.winner])
        self.out.close()

    def main(self):
        #self.coor = open('coor', 'w')
        #self.out = open('out', 'w')
        #self.out.close()
        #self.log = open('log', 'w')
        command = self.query_command()
        if command['command'] != 'start':
            self.report_error('Expect start command')
            return
        #max number of turn is 60
        self.turn = 0
     #   flag = 1
        for i in range(100):
       #     if flag:
            #self.prt()
      #      flag = 1

            command = self.query_player(self.turn)

            #Assuming command is either 'player', 'error' or 'terminated'
            #If command is 'error' or 'terminated', the other player win
            if command['command'] != 'player':
                self.winner = 1 - self.turn
                break

            player = command['player']
            if player != self.turn:
                break

            try:
                x, y = (int(_) for _ in command['stdout'].split())
     #           self.coor.write(command['stdout'])
            except:
                self.winner = 1 - self.turn
                break

            if not self.valid_move(player, x, y):
     #           flag = 0
     #           continue
                self.winner = 1 - self.turn
                break

            self.update(player, x, y, False)
            self.turn = self.next_player()
            if self.turn == -1:
                break
        self.report_winner()
     #   self.prt()

if __name__ == '__main__':
    verdict = Verdict()
    verdict.main()