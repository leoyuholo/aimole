import React from 'react';
import Paper from 'material-ui/lib/paper';

import Game from 'gameExample/ticTacToe/index.jsx';

import Styles from 'Styles.jsx';

const paperStyle = {
    margin: '10px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
};

const pluginStyle = {
    backgroundColor: 'white',
    height: '360px',
    width: '640px',
    overflow: 'hidden',
    border: 'none'
};

const nodeStyle = {
    marginTop: '0px'
};


export default class CodingIndex extends React.Component {
    render() {
        return (
            <Paper zDepth={Styles.paper.zDepth} style={paperStyle}>
                <Paper zDepth={0} style={pluginStyle}>
                    <div style={nodeStyle}>
                        <Game result={this.props.result} />
                    </div>
                </Paper>
            </Paper>
        );
    }
}
