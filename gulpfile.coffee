#Change this to the folder that serves your local webpages.
#this is where you want to setup your git repo for the class
#as well. 
serverDir = '/Library/WebServer/Documents/'

#Change this to the URL you type in your browser to view 
#your webserver.  This will typically be 'localhost'
localServerURL = "cs313.dev"

#Don't change these
gulp         = require 'gulp'
gutil        = require 'gulp-util'
plumber      = require 'gulp-plumber'
chmod        = require 'gulp-chmod'
changed      = require 'gulp-changed'
accord       = require 'gulp-accord'
autoprefixer = require 'gulp-autoprefixer'
axis         = require 'axis'
rupture      = require 'rupture'
nib          = require 'nib'
jeet         = require 'jeet'
axis         = require 'axis'
jshint       = require 'gulp-jshint'
concat       = require 'gulp-concat'
uglify       = require 'gulp-uglify'
jade         = require 'gulp-jade'
coffee       = require 'gulp-coffee'
coffeelint   = require 'gulp-coffeelint'
shell        = require 'gulp-shell'
watch        = require 'gulp-watch'
imagemin     = require 'gulp-imagemin'
pngquant     = require 'imagemin-pngquant'
cached       = require 'gulp-cached'
gulpif       = require 'gulp-if'
filter       = require 'gulp-filter'
jadeInh      = require 'gulp-jade-inheritance'
browserSync  = require 'browser-sync'
sourcemaps   = require 'gulp-sourcemaps'
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
  stylusImport: 'app/styles/imports/*.styl'
  php:          'app/php/**/*.php'
#You shouldn't need to change these either.
#This is where your files end up.
dest = 
  html:    serverDir
  css:     serverDir + "css/"
  js:      serverDir + "js/"
  img:     serverDir + "images/"
  php:     serverDir + "php/"
  server:  serverDir + "**/*"

#My Error Handler
onError = (err) ->
  displayErr = gutil.colors.red(err)
  gutil.log displayErr
  gutil.beep()
  this.emit('end')

#Change jade into html
gulp.task 'jade', (event) -> 
  gulp.src src.jade,
    base: 'app/jade/'
  .pipe changed dest.html,
    extension: '.html'
  .pipe plumber
    errorHandler: onError
  .pipe gulpif global.isWatching, cached 'jade'
  .pipe jadeInh
    basedir: 'app/jade/'
  .pipe filter (file) ->
    return !/\/_/.test(file.path) or !/_/.test(file.relative)
  .pipe jade
    #change this to false for production
    pretty: true
  .pipe gulp.dest dest.html
    
#Change coffeescript to javascript
gulp.task 'coffee', ->
  gulp.src src.coffee,
    base: 'app/scripts'
  .pipe plumber
    errorHandler: onError
  .pipe coffeelint
    optFile: 'coffeelint.json'
  .pipe coffeelint.reporter()
  .pipe sourcemaps.init()
  .pipe coffee
    bare: true
  .pipe uglify()
  .pipe concat 'all.js'
  .pipe sourcemaps.write()
  .pipe chmod 755
  .pipe gulp.dest dest.js
  
#Change stylus to CSS3
gulp.task 'stylus', ->
  gulp.src [src.stylus, src.stylusImport],
    base: 'app/styles/'
  .pipe plumber
    errorHandler: onError
  .pipe sourcemaps.init()
  .pipe stylus
  #these are each plugins for stylus. Google them, and profit.
    use: [
       nib()
       jeet()
       rupture()
       axis()
    ]
    import:[src.stylusImport]
  .on 'error', onError 
  #no more vender prefixing! Hurray!
  .pipe autoprefixer
    browsers: ['last 2 versions']
    cascade: true
  #concatenate all of your CSS files into one file
  .pipe concat 'main.css'
  .pipe sourcemaps.write()    
  .pipe gulp.dest dest.css

#optimize your images!
gulp.task 'images', ->
    gulp.src src.img,
      base: 'app/images'
    .pipe(changed(dest.img))
    .pipe imagemin
      optimizationLevel: 7
      progressive: true
      interlaced: true
      svgoPlugins: [removeViewBox: false]
      use: [pngquant()]
    .pipe chmod 755
    .pipe gulp.dest dest.img
    
#Add all of your changes and push them to your git repo
#located at serverDir
gulp.task 'git', shell.task [
    'sleep .1 && cd ' +  serverDir + ' && git add --all && git commit -m \"Gulp Commit\" && git push'
  ]

#move php files
gulp.task 'php', ->
  gulp.src src.php,
    base: 'app/php'
  .pipe gulp.dest dest.php
  
#this might be redundant
gulp.task 'setWatch', ->
  global.isWatching = true

#browserSync can watch on its own.
gulp.task 'browser-sync', ->
  browserSync
    files: [
      serverDir + '**/*.html'
      serverDir + '**/*.css'
      serverDir + '**/*.js'
      serverDir + '**/*.png'
      serverDir + '**/*.jpg'
      serverDir + '**/*.php'
    ]
    proxy: localServerURL
    notify: false

#This watches for changes 
gulp.task 'default', ['setWatch', 'browser-sync'], ->
  gulp.watch src.img, ['images']
  gulp.watch src.stylus, ['stylus']
  gulp.watch src.coffee, ['coffee']
  gulp.watch src.jade, ['jade']
  gulp.watch src.php, ['php']
  