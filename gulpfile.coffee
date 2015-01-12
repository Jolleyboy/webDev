#Don't change these
gulp         = require 'gulp'
gutil        = require 'gulp-util'
changed      = require 'gulp-changed'
accord       = require 'gulp-accord'
autoprefixer = require 'gulp-autoprefixer'
axis         = require 'axis-css'
rupture      = require 'rupture'
nib          = require 'nib'
jeet         = require 'jeet'
axis         = require 'axis'
jshint       = require 'gulp-jshint'
concat       = require 'gulp-concat'
imagemin     = require 'gulp-imagemin'
notify       = require 'gulp-notify'
plumber      = require 'gulp-plumber'
stripDebug   = require 'gulp-strip-debug'
uglify       = require 'gulp-uglify'
jade         = require 'gulp-jade'
rename       = require 'gulp-rename'
sftp         = require 'gulp-sftp'
changed      = require 'gulp-changed'
coffee       = require 'gulp-coffee'
browserify   = require 'gulp-browserify'
clean        = require 'gulp-clean'
livereload   = require 'gulp-livereload'
shell        = require 'gulp-shell'
stylus       = (opts) -> accord 'stylus', opts

#change this to the folder that serves your local webpages.
#this is where you want to setup your git repo for the class
#as well.
serverDir = '/Library/WebServer/Documents'

#you shouldn't need to change these.
src = 
  index:        'app/index.html'
  html:         'app/views/*.html'
  jade:         'app/jade/*.jade'
  coffee:       'app/scripts/**/*.coffee'
  jIndex:       'app/jade/index.jade'
  js:           'app/scripts/**/*.js'
  stylus:       'app/styles/*.styl'
  img:          'app/images/*'
  vendor:       'app/vendor/*.js' 
  stylusImport: 'app/styles/imports/*'

#you shouldn't need to change these either.
dest = 
  index:   serverDir
  html:    serverDir
  css:     serverDir + "css/"
  js:      serverDir + "js/"
  img:     serverDir
  php:     serverDir
  server:  serverDir + "**/*"

#Change jade into html
gulp.task 'jade', (event) -> 
  gulp.src src.jade
  .pipe jade
    #change this to false for production
    pretty: true
  .pipe gulp.dest dest.index
  .pipe livereload()

#lint your javascript!! Useful for finding errors
gulp.task 'jshint', ->
  gulp.src src.js
    .pipe jshint()
    .pipe jshint.reporter 'default'

#Concatenate all of your javascript files into one file
gulp.task 'prepJS', ->
  gulp.src [src.js, src.vendor]
  .pipe concat 'all.js'
  #uncomment this for production
  #.pipe uglify()
  .pipe gulp.dest dest.js
  .pipe livereload()

#Change coffeescript to javascript
gulp.task 'coffee', ->
  gulp.src src.coffee
  .pipe coffee
    bare: true
  .on 'error', gutil.log
  .pipe gulp.dest 'app/scripts/'

#Change stylus to CSS3
gulp.task 'styles', ->
  gulp.src src.stylus
  .pipe stylus
  #these are each plugins for stylus. Google them, and profit.
    use: [
       nib()
       jeet()
       rupture()
       axis()
    ]
    import:['app/styles/imports/*']
  #no more vender prefixing! Hurray!
  .pipe autoprefixer
    browsers: ['last 2 versions']
    cascade: true
  #concatenate all of your CSS files into one file
  .pipe concat 'main.css'  
  .pipe gulp.dest dest.css
  .pipe livereload()

#Add all of your changes and push them to your git repo
#located at serverDir
gulp.task 'git', shell.task [
    'cd' +  serverDir + ' && git add . && git commit -m \"Gulp Commit\" && git push'
  ]

#This watches for changes 
gulp.task 'default', ->
  livereload.listen()
  gulp.watch src.stylus, ['styles']
  gulp.watch src.coffee, ['coffee']
  gulp.watch src.js, ['jshint', 'prepJS']
  gulp.watch src.jade, ['jade']
  gulp.watch dest.server, ['git']
