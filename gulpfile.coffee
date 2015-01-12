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

src = 
  index:   'app/index.html'
  html:    'app/views/*.html'
  jade:    'app/jade/*.jade'
  jIndex:  'app/jade/index.jade'
  js:      'app/scripts/*.js'
  stylus:  'app/styles/*.styl'
  img:     'app/images/*'
  vendor:  'app/vendor/*.js'

dest = 
  index:   '/Library/WebServer/Documents/'
  html:    "/Library/WebServer/Documents/"
  css:     "/Library/WebServer/Documents/css/"
  js:      "/Library/WebServer/Documents/js/"
  img:     "/Library/WebServer/Documents/"
  php:     "/Library/WebServer/Documents/"

gulp.task 'jade', (event) -> 
  gulp.src src.jade
  .pipe jade
    pretty: true
  .pipe gulp.dest dest.index
  .pipe livereload()
  

# gulp.task 'images', ->
#   gulp.src src.img
#   .pipe changed dest.img
#   .pipe imagemin 
#   .pipe gulp.dest dest.img
#   .pipe notify
#     message: 'Images task complete'

gulp.task 'jshint', ->
   gulp.src src.js
   .pipe jshint()
   .pipe jshint.reporter 'default'
   .pipe livereload()

gulp.task 'prepJS', ->
  gulp.src [src.js, src.vendor]
  .pipe concat 'all.js'
  #.pipe uglify()
  .pipe gulp.dest dest.js
  .pipe livereload()

gulp.task 'coffee', ->
  gulp.src ['app/scripts/**/*.coffee', 'app/scripts/*.coffee']
  .pipe coffee
      bare: true
  .on 'error', gutil.log
  .pipe gulp.dest 'app/scripts/'

gulp.task 'styles', ->
  gulp.src src.stylus
  .pipe stylus
    use: [
       nib()
       jeet()
       rupture()
       axis()
    ]
    import:['app/styles/imports/*']
  .pipe autoprefixer
    browsers: ['last 2 versions']
    cascade: true
  .pipe concat 'main.css'  
  .pipe gulp.dest dest.css
  .pipe livereload()

gulp.task 'git', shell.task [
    'cd /Library/WebServer/Documents/ && git add . && git commit -m \"Gulp Commit\" && git push'
  ]

gulp.task 'default', ->
  livereload.listen()
  gulp.watch src.stylus, ['styles']
  gulp.watch 'app/scripts/**/*.coffee', ['coffee']
  gulp.watch [src.js, 'app/scripts/**/*.js'], ['jshint', 'prepJS']
  gulp.watch src.jade, ['jade']
  gulp.watch '/Library/WebServer/Documents/**/*', ['git']
