import React from 'react';
import brace from 'brace';

import AceEditor from 'react-ace';

import 'brace/mode/c_cpp';
import 'brace/theme/chrome';

const aceStyle = {
    overflowX: 'scroll',
    border: '2px solid #EBEBEB',
    borderRadius: '2px'
};

export default class EditorAce extends React.Component {
    render() {
        return (
            <div style={aceStyle}>
                <AceEditor
                    name="codeAce"
                    mode="c_cpp"
                    theme="chrome"
                    width="100%"
                    height="600px"
                    fontSize={13.5}
                    onChange={this.props.handleCodeChange}
                    value={this.props.editorContent}
                />
            </div>
        );
    }
}
