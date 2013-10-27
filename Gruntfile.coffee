module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    bower:
      target:
        rjsConfig: "app/scripts/main.js"
    clean:
      test: [
        'bower_components'
      ]

  grunt.loadNpmTasks "grunt-bower-requirejs"

  grunt.registerTask 'bower-install', () ->
    done = @async()
    spawn = require('child_process').spawn
    ls = spawn 'bower', ['install']

    ls.stdout.on 'data', (data) ->
      grunt.log.write data

    ls.stderr.on 'data', (data) ->
      grunt.log.write data

    ls.on 'close', (code) ->
      grunt.log.writeln('child process exited with code ' + code)
      done()

  grunt.registerTask 'build', [
    'clean',
    'bower-install',
    'bower'
  ]

  grunt.registerTask "default", ["build"]