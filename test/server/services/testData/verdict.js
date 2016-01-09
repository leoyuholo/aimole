function print(json) {
    console.log(JSON.stringify(json))
}

process.stdin.on('data', function (data) {
    var gameUpdate = JSON.parse(data.toString());

    switch (gameUpdate.command) {
        case 'start':
            print({action: 'next', nextPlayer: 0, writeMsg: '1\n'});
            break;
        case 'player':
            var value = +gameUpdate.stdout.split('\n')[0];
            if (value > 100)
                print({action: 'stop'});
            else
                print({action: 'next', nextPlayer: (+gameUpdate.player+1)%2, writeMsg: value+'\n'});
            break;
        case 'timeout':
            print({action: 'stop'});
            break;
    }
});
