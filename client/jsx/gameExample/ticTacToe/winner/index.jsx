import React from 'react';

const winnerStyle = {
    position: 'absolute',
    top: '150',
    left: '50',
    width: '50px',
    height: '50px',
    padding: '20px',
    color: 'white'
};

const cardStyle = {
    padding: '10px'
};

export default class CurrentPlayer extends React.Component {
    getSymbol() {
        switch(this.props.val) {
            case '1':
                return 'O';
            case '2':
                return 'X';
            case '3':
                return 'DRAW';
            default:
                return '-';
        }
    }

    render() {
        return (
            <div style={winnerStyle}>
                <h5>WINNER</h5>
                <h2>{this.getSymbol()}</h2>
            </div>
        );
    }
}
