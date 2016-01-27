import React from 'react';
import Paper from 'material-ui/lib/paper';

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


export default class GameBoard extends React.Component {
    componentDidUpdate() {
        var event = new CustomEvent('updateResult', {
            detail: {
                currentFrame: this.props.currentFrame,
                result: this.props.result
            }
        });
        window.dispatchEvent(event);
    }
    
    render() {
        return (
            <Paper zDepth={Styles.paper.zDepth} style={paperStyle}>
                <Paper zDepth={0} style={pluginStyle}>
                    <div style={nodeStyle}>
                        <div id="gameEntryNode" />
                    </div>
                </Paper>
            </Paper>
        );
    }
}
