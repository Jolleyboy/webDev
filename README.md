WebDev
======

Hello fello CS313 class members!  (And other interested parties)

##Prerequisites:
* Local webserver installed. I recommend [XAMPP](https://www.apachefriends.org/download.html)
* Node.js installed and in your path. [Download](http://nodejs.org/download/)

##How to Setup:
* Clone this project, and open cmd/terminal in the repo directory
* type `npm -i` into the terminal and hit enter
* This installs all of the gulp plugins required for this project.
You will only need to run this command the first time.
*Edit gulpfile.coffee and change the serverDir variable to the directory your webserver is serving.
* type `gulp` into the terminal and hit enter. Leave it running in the background.
* Edit and save app/jade/index.jade, app/scripts/main.coffee and
* Init a new repo in the directory your webserver is serving and set it up with GitHub.


##How to use:
* Open cmd/terminal in the repo directory
* type `gulp` into the terminal and hit enter. Leave it running in the background.
* navigate your browser to http://localhost (or wherever you told your webserver to host on your local machine.)

That's it!  You're now setup to use:
* [Jade](http://jade-lang.com/)
* [Stylus](http://learnboost.github.io/stylus/)
* [CoffeeScript](http://coffeescript.org/) 

These are processed into HTML5, CSS3, and Javascript respectively. All you need do is edit a files (found in app/name-of-file-type).  When you save all of the processing, updating, linting, etc is done for you. When you save, your changes automatically reload the browser for easy development.  Images are also optimized for the web when added to app/images.

