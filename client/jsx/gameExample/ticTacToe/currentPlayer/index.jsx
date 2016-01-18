import React from 'react';

const currentPlayerStyle = {
    position: 'absolute',
    top: '30',
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
            default:
                return '-';
        }
    }

    render() {
        return (
            <div style={currentPlayerStyle}>
                <h5>CURRENT PLAYER</h5>
                <h2>{this.getSymbol()}</h2>
                <hr />
            </div>
        );
    }
}
