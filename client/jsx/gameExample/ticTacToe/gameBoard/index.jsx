import React from 'react';

import Styles from '../styles.jsx';
import Cell from './cell.jsx';

const mainStyle = {
    position: 'absolute',
    top: '50',
    left: '200'
};

export default class Game extends React.Component {
    render() {
        var tbody = this.props.gameResult.map((row, i) => (
            <tr key={`row${i}`}>
                {row.map((cell, j) => (
                    <Cell key={`cell${i}${j}`} val={cell} />
                ))}
            </tr>
        ));

        return (
            <table style={mainStyle}>
                <tbody>
                    {tbody}
                </tbody>
            </table>
        );
    }
}
