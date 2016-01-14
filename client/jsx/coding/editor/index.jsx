import React from 'react';

import RaisedButton from 'material-ui/lib/raised-button';
import Paper from 'material-ui/lib/paper';

import Styles from 'Styles.jsx';

import EditorAce from './ace.jsx';

const btnSubmitColor = {
    marginTop: '10px'
};

export default class EditorCard extends React.Component {
    constructor() {
        super();
        this.state = {
            code: ''
        };
        this.handleCodeChange = this.handleCodeChange.bind(this);
    }
    handleCodeChange(code) {
        this.setState({ code: code });
    }
    render() {
        return (
            <Paper zDepth={Styles.paper.zDepth} style={Styles.paper.style}>
                <h5>Your Code:</h5>
                <EditorAce
                    handleCodeChange={this.handleCodeChange}
                    editorContent={this.state.code} />
                <RaisedButton
                    style={btnSubmitColor}
                    onTouchTap={this.props.handleSubmit.bind(this, this.state.code)}
                    label="Submit"
                    primary={true} />
            </Paper>
        );
    }
}
