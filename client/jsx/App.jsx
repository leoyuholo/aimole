import React from 'react';
import ReactDOM from 'react-dom';

import CodingIndex from './coding/index.jsx';
import Header from './header/index.jsx';

import injectTapEventPlugin from 'react-tap-event-plugin';

injectTapEventPlugin();

ReactDOM.render(<CodingIndex />, document.getElementById('content'));

ReactDOM.render(<Header />, document.getElementById('header'));
