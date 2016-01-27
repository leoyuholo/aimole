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
        this.state = {
            currentFrame: 0,
            currentPlayer: 0,
            result: [['0','0','0'], ['0','0','0'], ['0','0','0']],
            winner: 0
        };
    }

    componentDidMount() {
        window.addEventListener('updateResult', e => {
            this.setState({
                currentFrame: e.detail.currentFrame? e.detail.currentFrame: this.state.currentFrame,
                result: e.detail.result? e.detail.result: this.state.result,
            });
        });
    }

    render() {
        return (
            <div style={mainStyle}>
                <GameBoard result={this.state.result} />
                <CurrentPlayer val={this.state.currentPlayer} />
                <Winner val={this.state.winner} />
            </div>
        );
    }
}
