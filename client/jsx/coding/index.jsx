import React from 'react';
import $ from 'jquery-browserify';

import Editor from './editor/index.jsx';
import GameBoard from './gameBoard/index.jsx';
import Player from './player/index.jsx';

import Paper from 'material-ui/lib/paper';

const outerDivStyle = {
    display: 'flex',
    justifyContent: 'center',
    flexWrap: 'wrap'
};

const fixedInnerStyle = {
    flex: '0 0 660px',
    margin: '20px',
    marginRight: '10px',
    marginLeft: '20px'
};

const variableInnerStyle = {
    flexGrow: '1',
    minWidth: '300px',
    margin: '20px',
    marginRight: '20px',
    marginLeft: '10px'
};

export default class CodingIndex extends React.Component {
    constructor() {
        super();
        this.state = {
            currentFrame: 0,
            submitted: false,
            result: []
        };
        this.setCurrentFrame = this.setCurrentFrame.bind(this);
        this.getCurrentFrameResult = this.getCurrentFrameResult.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    setCurrentFrame(val) {
        if (val >= 0 && val < this.state.result.length)
            this.setState({currentFrame: val});
    }

    getCurrentFrameResult() {
        //console.log('this.state.result ', this.state.result);
        if (this.state.submitted === false)
            return undefined;
        else
            return this.state.result[this.state.currentFrame].display;
    }

    handleSubmit(code) {
        this.setState({
            submitted: true,
            result: undefined
        });
        $.ajax({
            url: '/api/game/submit',
            type: 'POST',
            data: JSON.stringify({code: code}),
            contentType: "application/json",
            success: msg => {
                //console.log(msg);
                this.setState({result: msg.gameResult});
            },
            error: err => {
                console.error(err);
            }
        });
    }

    render() {
        return (
            <div style={outerDivStyle}>
                <div style={fixedInnerStyle}>
                    <GameBoard
                        handlePlayerClick={this.handlePlayerClick}
                        result={this.getCurrentFrameResult()}
                        currentFrame={this.state.currentFrame} />
                    <Player
                        setCurrentFrame={this.setCurrentFrame}
                        currentFrame={this.state.currentFrame}
                        lastFrame={this.state.result.length - 1}
                        submitted={this.state.submitted} />
                </div>
                <div style={variableInnerStyle}>
                    <Editor handleSubmit={this.handleSubmit}/>
                </div>
            </div>
        );
    }
}
