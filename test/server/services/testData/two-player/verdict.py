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

    def send_action(self, action):
        print(json.dumps(action))

    def report_error(self, error_message):
        return
        action = {
                    'action' : 'error',
                    'errorMessage' : error_message
                 }
        self.send_action(action)

    def report_winner(self):
        self.display['board'] = [[x + 1 for x in row] for row in self.board]
        action = {
                    'action' : 'stop',
                    'winner' : self.winner,
                    'score' : self.score,
                    'display' : self.display,
                    'goodGame' : self.good_game
                 }
        self.send_action(action)

    def query_command(self):
        json_string = raw_input()
        command = json.loads(json_string)
        return command

    def query_player(self, player):
        mp = {
                self.EMPTY : '.',
                self.BLACK : 'B',
                self.WHITE : 'W'
             }
        player_input = mp[player] + ' ' + mp[1 - player] + '\n'
        player_input += '\n'.join([''.join([mp[_] for _ in row]) for row in self.board]) + '\n'
        self.display['board'] = [[x + 1 for x in row] for row in self.board]

        action = {
                    'action' : 'next',
                    'nextPlayer' : player,
                    'writeMsg' : player_input,
                    'display' : self.display,
                    'timeLimit' : 2000
                 }

        self.send_action(action)
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

    def main(self):
        command = self.query_command()
        if command['command'] != 'start':
            self.report_error('Expect start command')
            return
        self.players = command['players']
        self.display = { 'players' : self.players }
        self.turn = 0

        #max number of turn is 60
        for i in range(60):
            command = self.query_player(self.turn)

            self.display = {
                            'player' : self.turn,
                            'score' : self.score,
                            'time' : command['time']
                           }
            #Assuming command is either 'player', 'error', 'timeout' or 'terminated'
            #If command is 'error', 'timeout' or 'terminated', the other player win
            if command['command'] != 'player':
                if command['command'] == 'terminated':
                    message = 'terminated %d %s' % (command['exitCode'], command['signalStr'])
                elif command['command'] == 'error':
                    message = 'error %s' % (command['errorMessage'])
                elif command['command'] == 'timeout':
                    message = 'timeout %d' % command['time']
                else:
                    message = 'unexpected_error'
                self.display['message'] = [message]
                self.winner = 1 - self.turn
                break

            player = command['player']
            if player != self.turn:
                break

            if len(command['stdout']) > 1000:
                self.display['stdout'] = command['stdout'][:1000] + '...'
            else:
                self.display['stdout'] = command['stdout']

            try:
                x, y = (int(_) for _ in command['stdout'].split())
            except:
                self.winner = 1 - self.turn
                self.display['message'] = ['invalid %d' % (player + 1)]
                break

            self.display['position'] = [x, y]

            if not self.valid_move(player, x, y):
                self.winner = 1 - self.turn
                self.display['message'] = ['invalid %d' % (player + 1)]
                break
            self.display['message'] = ['ok']
            self.update(player, x, y, False)
            self.turn = self.next_player()
            if self.turn == -1:
                break

        self.good_game = True if self.winner == -1 else False
        if self.winner == -1:
            if self.score[0] != self.score[1]:
                self.winner = 1 if self.score[1] > self.score[0] else 0

        self.display['message'].append('draw' if self.winner == -1 else 'winner %d' % (self.winner + 1))
        self.report_winner()

if __name__ == '__main__':
    verdict = Verdict()
    verdict.main()
