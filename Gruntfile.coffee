path = require 'path'
src = [ "lib/**/*.coffee", "index.coffee" ]
dist = 'dist'
jison = './node_modules/.bin/jison'

jisonOutFile = ( file ) ->
  outFile = path.join __dirname, "dist/#{file}.js"

jisonOutDir = ( file ) ->
  path.dirname jisonOutFile file

jisonCmd = ( file ) ->
  outFile = jisonOutFile file
  "#{jison} -o #{outFile} #{file}.jison"

config = ( grunt ) ->
  tasks :
    coffee :
      options : { sourceMap : false, bare : true, force : true }
      dist : { expand : true, src : src, dest : dist, ext : '.js' }

    clean : { dist : [ dist, "*.{js,map}", "lib/**/*.{map,js}" ] }

    coffeelint : { app : src }

    watch : { coffee : { tasks : [ 'coffee' ], files : src } }

    mkdir :
      jison :
        options :
          create : [ jisonOutDir('lib/grammar/fsm') ]
  
    copy:
      jison:
        src: 'dist/lib/grammar/fsm.js'
        dest: 'lib/grammar/fsm.js'

    exec :
      jison : { cmd : jisonCmd 'lib/grammar/fsm' }
      mocha : { cmd : 'mocha --require ./coffee-coverage-loader.coffee' }
      istanbul : { cmd : 'istanbul report lcov' }
      open_coverage : { cmd : 'open ./coverage/lcov-report/index.html' }

  register :
    coverage : [ 'exec:istanbul', 'exec:open_coverage' ]
    test : [ 'exec:mocha', 'coverage' ]
    jison : [ 'mkdir:jison', 'exec:jison', 'copy:jison' ]
    default : [ 'coffeelint', 'clean:dist', 'coffee:dist', 'jison' ]

doConfig = ( cfg ) -> ( grunt ) ->
  opts = cfg grunt
  pkg = opts.tasks.pkg = grunt.file.readJSON "package.json"
  grunt.initConfig opts.tasks
  opts.load ?= []
  dev = Object.keys pkg.devDependencies
  deps = (f for f in dev when f.indexOf('grunt-') is 0)
  opts.load = opts.load.concat deps
  grunt.loadNpmTasks t for t in opts.load

  for own name, tasks of opts.register
    grunt.registerTask name, tasks

module.exports = doConfig config
