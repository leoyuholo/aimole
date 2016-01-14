import React from 'react';
import Styles from './styles.jsx';

import GameBoard from './gameBoard/index.jsx';
import CurrentPlayer from './currentPlayer/index.jsx';
import Winner from './winner/index.jsx';

const mainStyle = {
    position: 'relative',
    background: Styles.main.bg,
    height: '360px',
    width: '640px'
};

export default class Game extends React.Component {

    constructor() {
        super();
        this.getResult = this.getResult.bind(this);
        this.getCurrentPlayer = this.getCurrentPlayer.bind(this);
        this.getWinner = this.getWinner.bind(this);
    }

    getResult() {
        if (this.props.result === undefined)
            return [['0','0','0'], ['0','0','0'], ['0','0','0']];
        else
            return this.props.result.gameResult;
    }

    getCurrentPlayer() {
        if (this.props.result === undefined)
            return 0;
        else
            return this.props.result.currentPlayer;
    }

    getWinner() {
        if (this.props.result && this.props.result.winner !== undefined)
            return this.props.result.winner;
        else
            return 0;
    }

    render() {
        return (
            <div style={mainStyle}>
                <GameBoard gameResult={this.getResult()} />
                <CurrentPlayer val={this.getCurrentPlayer()} />
                <Winner val={this.getWinner()} />
            </div>
        );
    }
}
