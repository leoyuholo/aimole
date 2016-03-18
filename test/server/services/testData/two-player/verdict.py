import json
class TicTacToeVerdict:
    def __init__(self):
        self.board = [[0 for i in range(3)] for j in range(3)]
        self.turn = 0
        self.score = [0 for i in range(2)]
        self.dx = [1, 1, 0, -1]
        self.dy = [0, 1, 1, 1]
        self.winner = -1
        
    def send_action(self, action):
        print(json.dumps(action))

    def report_error(self, error_message):
        error = {
                    'action' : 'error',
                    'errorMessage' : error_message
                }
        self.send_action(error)
    
    def report_winner(self):
        self.score[self.winner] = 3
        action = {
                    'action' : 'stop',
                    'score' : self.score,
                    'display' : self.board
                 }
        self.send_action(action)
    
    def query_command(self):
        json_string = raw_input()
        command = json.loads(json_string)
        return command
    
    def query_player(self, player):
        if player == 0:
            message = '\n'.join([ ' '.join( [str(_) for _ in row]) for row in self.board ] ) + '\n'
        elif player == 1:
            message = '\n'.join([ ' '.join( [str( (3 ^ i) if i else 0 ) for i in row] ) for row in self.board ]) + '\n'
        action = {
                    'action' : 'next',
                    'nextPlayer' : player,
                    'writeMsg' : message,
                    'display' : self.board
                 }
        self.send_action(action)
        return self.query_command()
    
    def next_player(self):
        return 1 - self.turn
    
    def update(self, player, x, y):
        self.board[x][y] = player + 1
    
    def inside(self, x, y):
        return 0 <= x < 3 and 0 <= y < 3
    
    def valid_move(self, player, x, y):
        if self.turn != player or (not self.inside(x, y)) or self.board[x][y]:
            return False
        return True
    
    def end_game(self):
        if self.winner != -1:
            return True
        dx, dy, board = self.dx, self.dy, self.board
        for i in range(3):
            for j in range(3):
                if not board[i][j]:
                    continue
                for d in range(4):
                    if not self.inside(i + 2 * dx[d], j + 2 * dy[d]):
                        continue
                    ok = True
                    for l in range(3):
                        if board[i][j] != board[i + l * dx[d]][j + l * dy[d]]:
                            ok = 0
                            break
                    if ok:
                        self.winner = board[i][j] - 1
                        return True
        return False
    
    def main(self):
        command = self.query_command()
        if command['command'] != 'start':
            self.report_error('Expected start command')
            return
        while not self.end_game():
            command = self.query_player(self.turn)
            if command['command'] == 'player':
                player = command['player']
                try:
                    x, y = (int(_) for _ in command['stdout'].split())
                except:
                    self.report_error('Error when parsing player %d output: ' % (player) + command['stdout'])
                    self.winner = self.next_player()
                else:
                    if not self.valid_move(player, x, y):
                        self.report_error('Invalid player move')
                        self.winner = self.next_player()
                    else:
                        self.update(player, x, y)
            elif command['command'] == 'terminated':
                self.winner = self.next_player()
            elif command['command'] == 'error':
                self.winner = self.next_player()
            self.turn = self.next_player()
        self.report_winner()

if __name__ == '__main__':
    verdict = TicTacToeVerdict()
    verdict.main()
