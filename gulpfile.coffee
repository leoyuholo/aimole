requireDir = require 'require-dir'
requireDir './gulp'

gulp = require 'gulp'

gulp.task 'test', ['mocha']

gulp.task 'travis', ['lint', 'test']
gulp.task 'update-client', ['browserify', 'html']
gulp.task 'dev', ['watch', 'lint', 'update-client', 'nodemon']
gulp.task 'default', ['watch', 'update-client', 'nodemon']
