#Change this to the folder that serves your local webpages.
#this is where you want to setup your git repo for the class
#as well. 
serverDir = '/PATH/TO/WEBSERVER/'

#Change this to the URL you type in your browser to view 
#your webserver.  This will typically be 'localhost'
localServerURL = "localhost"

#Don't change these
gulp        = require 'gulp'
loadPlugins = require 'gulp-load-plugins'
plugins     = loadPlugins
  pattern: [
    'gulp-*'
    'gulp.*' 
    'main-bower-files'
    'axis'
    'rupture'
    'nib'
    'jeet'
    'browser-sync'
    'imagemin-pngquant'
    'run-sequence'
    ]
  replaceString: /\bgulp[\-.]/

stylus       = (opts) -> plugins.accord 'stylus', opts

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
  php:          'app/files_php/**/*.php'
  bower:        'bower_components/**/*.min.js'
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
  displayErr = plugins.util.colors.red(err)
  plugins.util.log displayErr
  plugins.util.beep()
  this.emit('end')

#Change jade into html
gulp.task 'jade', (event) -> 
  gulp.src src.jade,
    base: 'app/jade/'
  .pipe plugins.changed dest.html,
    extension: '.html'
  .pipe plugins.plumber
    errorHandler: onError
  .pipe plugins.if global.isWatching, plugins.cached 'jade'
  .pipe plugins.jadeInheritance
    basedir: 'app/jade/'
  .pipe plugins.filter (file) ->
    return !/\/_/.test(file.path) or !/_/.test(file.relative)
  .pipe plugins.jade
    #change this to false for production
    pretty: true
  .pipe plugins.rename
    extname: '.php'
  .pipe gulp.dest dest.html

#Change coffeescript to javascript
gulp.task 'coffee', ->
  gulp.src src.coffee,
    base: 'app/scripts'
  .pipe plugins.cached 'coffee'
  .pipe plugins.plumber
    errorHandler: onError
  .pipe plugins.coffeelint
    optFile: 'coffeelint.json'
  .pipe plugins.coffeelint.reporter()
  .pipe plugins.sourcemaps.init()
  .pipe plugins.coffee
    bare: true
  .pipe plugins.uglify()
  .pipe plugins.remember 'coffee'
  .pipe plugins.concat 'all.js'
  .pipe plugins.sourcemaps.write()
  .pipe plugins.chmod 755
  .pipe gulp.dest dest.js

#Add our vendor javascript stuff in to our JS file
gulp.task 'vendor', ->
  gulp.src [src.bower, dest.js + '*.js']
  .pipe plugins.cached 'vendor'
  .pipe plugins.plumber
    errorHandler: onError
  .pipe plugins.sourcemaps.init loadMaps:true
  .pipe plugins.uglify()
  .pipe plugins.remember 'vendor'
  .pipe plugins.concat 'all.js'
  .pipe plugins.sourcemaps.write()
  .pipe gulp.dest dest.js

#Bundle your vendor files in
gulp.task 'bundleJavaScript', ->
  plugins.runSequence 'coffee', 'vendor'

#Change stylus to CSS3
gulp.task 'stylus', ->
  gulp.src [src.stylus, src.stylusImport],
    base: 'app/styles/'
  .pipe plugins.cached 'stylus'
  .pipe plugins.plumber
    errorHandler: onError
  .pipe plugins.sourcemaps.init()
  .pipe stylus
  #these are each plugins for stylus. Google them, and profit.
    use: [
       plugins.nib()
       plugins.jeet()
       plugins.rupture()
       plugins.axis()
    ]
    import:[src.stylusImport]
  .on 'error', onError 
  #no more vender prefixing! Hurray!
  .pipe plugins.autoprefixer
    browsers: ['last 2 versions']
    cascade: true
  #plugins.concatenate all of your CSS files into one file
  .pipe plugins.remember 'stylus'
  .pipe plugins.concat 'main.css'
  .pipe plugins.sourcemaps.write()    
  .pipe gulp.dest dest.css

#optimize your images!
gulp.task 'images', ->
    gulp.src src.img,
      base: 'app/images'
    .pipe plugins.cached 'images'
    .pipe plugins.imagemin
      optimizationLevel: 7
      progressive: true
      interlaced: true
      svgoPlugins: [removeViewBox: false]
      use: [plugins.imagemin-pngquant()]
    .pipe plugins.chmod 755
    .pipe gulp.dest dest.img
    
#Add all of your changes and push them to your git repo
#located at serverDir
gulp.task 'git', plugins.shell.task [
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
  plugins.browserSync
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
  imgWatch = gulp.watch src.img, ['images']
  cssWatch = gulp.watch src.stylus, ['stylus']
  jsWatch  = gulp.watch src.coffee, ['bundleJavaScript']
  jadeWatch= gulp.watch src.jade, ['jade']
  gulp.watch src.php, ['php']
  
  imgWatch.on 'change', (event) ->
    if event.type is 'deleted'
      delete plugins.cached.caches['images'][event.path]
      plugins.remember.forget 'images', event.path 

  cssWatch.on 'change', (event) ->
    if event.type is 'deleted'
      delete plugins.cached.caches['stylus'][event.path]
      plugins.remember.forget 'stylus', event.path
  
  jsWatch.on 'change', (event) ->
    if event.type is 'deleted'
      delete plugins.cached.caches['vendor'][event.path]
      plugins.remember.forget 'vendor', event.path
      delete plugins.cached.caches['coffee'][event.path]
      plugins.remember.forget 'coffee', event.path
  
  jadeWatch.on 'change', (event) ->
    if event.type is 'deleted'
      delete plugins.cached.caches['jade'][event.path]
      plugins.remember.forget 'jade', event.path