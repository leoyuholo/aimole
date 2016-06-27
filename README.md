# aimole
> Let AI play against AI

*aimole* is a platform for game playing AI to play against other game playing AI. It is initially developed to support the online course taught by [Dr. Wong Tsz Yeung](http://www.cse.cuhk.edu.hk/~tywong/html/index.html) at [CUHK](http://www.cuhk.edu.hk), see the course [here](http://tywong.github.io/gitbook-engg1110/).

Besides this AI competing platform, there is also an online judge for programming assignments. See [codeSubmit](https://github.com/leoyuholo/codesubmit).

## Games
aimole is modularized to two parts, platform and games. Currently have two games developed and available.

### [Othello](https://github.com/ymcatar/aimole-othello)
![screenshot](./aimole-othello.png)

### [2048](https://github.com/jjanicechen/aimole-2048)
![screenshot](./aimole-2048.png)

## Sandbox-run
All the user submitted code are running inside sandbox environment. For each code execution, codeSubmit will spawn docker instances to run the compilation and execution process. This isolates each submission as well as providing security to the host.

This sandbox is a sub-project of Dr. Wong Tsz Yeung's students' final year project. You can find its docker hub repository [here](https://hub.docker.com/r/tomlau10/sandbox-run/).

# LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
