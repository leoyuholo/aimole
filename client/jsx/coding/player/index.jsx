import React from 'react';
import Paper from 'material-ui/lib/paper';

import FloatingActionButton from 'material-ui/lib/floating-action-button';
import FontIcon from 'material-ui/lib/font-icon';
import IconButton from 'material-ui/lib/icon-button';
import Slider from 'material-ui/lib/slider';

import Styles from 'Styles.jsx';

const playerStyle = {
    margin: '10px',
    padding: '10px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
};

const sliderDivStyle = {
    marginLeft: '15px',
    width: '200px',
    height: '18px'
};

const sliderStyle = {
    margin: '0px'
};

const labelStyle = {
    marginLeft: '20px',
    width: '15px',
    fontWeight: 'bold',
    color: 'grey'
};

export default class Player extends React.Component {

    constructor() {
        super();
        this.handleSliderChange = this.handleSliderChange.bind(this);
        this.handlePrev = this.handlePrev.bind(this);
        this.handleNext = this.handleNext.bind(this);
        this.handlePlay = this.handlePlay.bind(this);
    }

    handleSliderChange(e, val) {
        this.props.setCurrentFrame.call(this, Math.round(val * this.props.lastFrame));
        this.props.setPlay.call(this, false);
    }

    handlePrev() {
        this.props.setCurrentFrame.call(this, this.props.currentFrame - 1);
        this.props.setPlay.call(this, false);
    }

    handleNext() {
        this.props.setCurrentFrame.call(this, this.props.currentFrame + 1);
        this.props.setPlay.call(this, false);
    }

    handlePlay(val) {
        if (this.props.playing === false) { // initially pausing
            this.props.setCurrentFrame.call(this, this.props.currentFrame + 1);
            this.props.setPlay.call(this, true);
        } else {
            this.props.setPlay.call(this, false);
        }
    }

    componentDidUpdate() {
        if (this.props.playing && this.props.currentFrame < this.props.lastFrame)
            setTimeout(() => {
                if (this.props.playing)
                    this.props.setCurrentFrame.call(this, this.props.currentFrame + 1);
            }, 1500);
    }

    render() {
        return (
            <Paper style={playerStyle}>

                <IconButton
                    onTouchTap={this.handlePrev}
                    disabled={!this.props.submitted || this.props.currentFrame === 0}
                    iconClassName="material-icons">
                    fast_rewind
                </IconButton>

                <FloatingActionButton
                    onTouchTap={this.handlePlay}
                    disabled={!this.props.submitted || this.props.currentFrame === this.props.lastFrame}
                    mini={true}
                    primary={true}>
                    <FontIcon className="material-icons">
                        {this.props.playing? 'pause' : 'play_arrow'}
                    </FontIcon>
                </FloatingActionButton>

                <IconButton
                    onTouchTap={this.handleNext}
                    disabled={!this.props.submitted || this.props.currentFrame === this.props.lastFrame}
                    iconClassName="material-icons">
                    fast_forward
                </IconButton>

                <div style={sliderDivStyle}>
                    <Slider
                        onChange={this.handleSliderChange}
                        disabled={!this.props.submitted}
                        value={this.props.currentFrame/this.props.lastFrame}
                        step={1/this.props.lastFrame}
                        style={sliderStyle} />
                </div>

                <p style={labelStyle}>
                    {this.props.submitted? `${this.props.currentFrame + 1}/${this.props.lastFrame + 1}`: '-/-'}
                </p>
            </Paper>
        );
    }
}
