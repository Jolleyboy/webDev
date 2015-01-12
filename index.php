<!DOCTYPE html>
<html>
  <head>
    <title>Hello World</title>
    <script>
    function doIt() {
      var text = document.getElementById("myText").value;
      document.getElementById("putItHere").innerHTML += "<br/>" + text;
      document.getElementById("putItHere").style.background = text;
    }
    function toggle(){
      var displayed = document.getElementById("putItHere").style.display;
      if (displayed == "none")
        document.getElementById("putItHere").style.display = "block";
      else
        document.getElementById("putItHere").style.display = "none";
    }
    </script>
  </head>
  <body>
    <div>
      <h1>Hello World!</h1>
      <p>This is the moment.  Right?  Riight!</p>
      <input id="myText" type="text"/>
      <button onclick="doIt();">Click Me!</button>
      <button onclick="toggle();">Show/Hide</button>
    </div>
    <div id="putItHere">
    </div>
  </body>
</html>
