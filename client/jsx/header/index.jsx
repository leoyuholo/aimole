import React from 'react';
import AppBar from 'material-ui/lib/app-bar';

import Styles from 'Styles.jsx';

export default class Header extends React.Component {
    render() {
        return (
            <AppBar
                style={{
                    backgroundColor: Styles.header.bgColor
                }}
                titleStyle={{
                    color: Styles.header.color,
                    fontWeight: 'bolder'
                }}
                showMenuIconButton={false}
                title="aimole"
                zDepth={1}
            />
        );
    }
}
