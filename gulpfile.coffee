requireDir = require 'require-dir'
requireDir './gulp'

gulp = require 'gulp'

gulp.task 'travis', []
gulp.task 'dev', ['html', 'watch', 'lint-js', 'lint-coffee', 'nodemon']
gulp.task 'default', ['html', 'watch', 'lint-js', 'lint-coffee', 'nodemon']
