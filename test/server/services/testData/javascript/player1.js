'use strict'

/* write your compute function
 * it takes in a 8 * 8 board, your disc and your opponents' disc
 * return your next move by returning an array of [x, y]
 */
const compute = (me, opponent, board) => {
	// only valid for the first move, give this AI more capability!
	if (me == 'W') {
		return [2, 3];
	} else {
		return [4, 2];
	}
}

process.stdin.on('data', data => {
	const lines = data.toString().split('\n');
	const me = lines[0].charAt(0);
	const opponent = lines[0].charAt(2);
	const board = lines.slice(1, lines.length - 1);
	console.log(compute(me, opponent, board).join(' '));
});
