#Change this to the folder that serves your local webpages.
#this is where you want to setup your git repo for the class
#as well. 
serverDir = '/Library/WebServer/Documents/'

#Don't change these
gulp         = require 'gulp'
gutil        = require 'gulp-util'
plumber      = require 'gulp-plumber'
accord       = require 'gulp-accord'
autoprefixer = require 'gulp-autoprefixer'
axis         = require 'axis-css'
rupture      = require 'rupture'
nib          = require 'nib'
jeet         = require 'jeet'
axis         = require 'axis'
jshint       = require 'gulp-jshint'
concat       = require 'gulp-concat'
uglify       = require 'gulp-uglify'
jade         = require 'gulp-jade'
coffee       = require 'gulp-coffee'
clean        = require 'gulp-clean'
livereload   = require 'gulp-livereload'
shell        = require 'gulp-shell'
watch        = require 'gulp-watch'
imageop      = require 'gulp-image-optimization'
stylus       = (opts) -> accord 'stylus', opts

#You shouldn't need to change these.
#This is where the source files are located. 
src = 
  html:         'app/html/**/*.html'
  css:          'app/css/**/*.css'
  jade:         'app/jade/**/*.jade'
  coffee:       'app/scripts/**/*.coffee'
  js:           'app/scripts/**/*.js'
  stylus:       'app/styles/**/*.styl'
  img:          'app/images/**/*'
  vendor:       'app/vendor/**/*.js' 
  stylusImport: 'app/imports/**/*.styl'

#You shouldn't need to change these either.
#This is where your files end up.
dest = 
  html:    serverDir
  js:      serverDir + "js/"
  img:     serverDir + "images/"
  php:     serverDir
  server:  serverDir + "**/*"

onError = (err) ->
  gutil.beep()
  console.log err

#Change jade into html
gulp.task 'jade', (event) -> 
  gulp.src src.jade
  .pipe plumber
    errorHandler: onError
  .pipe jade
    #change this to false for production
    pretty: true
  .pipe gulp.dest dest.html

#lint your javascript!! Useful for finding errors
gulp.task 'jshint', ->
  gulp.src src.js
    .pipe jshint()
    .pipe jshint.reporter 'default'

#Concatenate all of your javascript files into one file
gulp.task 'prepJS', ->
  gulp.src [src.js, src.vendor]
  .pipe plumber
    errorHandler: onError
  .pipe concat 'all.js'
  #uncomment this for production
  #.pipe uglify()
  .pipe gulp.dest dest.js

#Change coffeescript to javascript
gulp.task 'coffee', ->
  gulp.src src.coffee
  .pipe plumber
    errorHandler: onError
  .pipe coffee
    bare: true
  .on 'error', gutil.log
  .pipe gulp.dest 'app/scripts/'

#Change stylus to CSS3
gulp.task 'styles', ->
  gulp.src src.stylus
  .pipe plumber
    errorHandler: onError
  .pipe stylus
  #these are each plugins for stylus. Google them, and profit.
    use: [
       nib()
       jeet()
       rupture()
       axis()
    ]
    import:[src.stylusImport]
  #no more vender prefixing! Hurray!
  .pipe autoprefixer
    browsers: ['last 2 versions']
    cascade: true
  #concatenate all of your CSS files into one file
  .pipe concat 'main.css'    
  .pipe gulp.dest dest.css
  .pipe livereload()

#optimize your images!
gulp.task 'images', (cb) ->
    gulp.src src.img
    .pipe plumber
    errorHandler: onError
    .pipe imageop
      optimizationLevel: 5,
      progressive: true,
      interlaced: true
    .pipe gulp.dest dest.img
    .on 'end', cb
    .on 'error', cb

#Add all of your changes and push them to your git repo
#located at serverDir
gulp.task 'git', shell.task [
    'sleep .25 && cd ' +  serverDir + ' && git add --all && git commit -m \"Gulp Commit\" && git push'
  ]

#reload the page
gulp.task 'reload', ->
  gulp.src dest.server,
    read: false
  .pipe plumber
    errorHandler: onError
  .pipe watch(dest.server)
  .pipe livereload()

gulp.task 
#This watches for changes 
gulp.task 'default', ->
  livereload.listen()
  gulp.watch src.img, ['images']
  gulp.watch src.stylus, ['styles']
  gulp.watch src.coffee, ['coffee']
  gulp.watch src.js, ['jshint', 'prepJS']
  gulp.watch src.jade, ['jade']
  gulp.watch dest.server, ['reload', 'git']
