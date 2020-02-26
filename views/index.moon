import Widget from require "lapis.html"

class extends Widget
  content: =>
    script src: "static/js/jquery/jquery.terminal-2.14.1.min.js"
    link rel: "stylesheet", href: "static/js/jquery/jquery.terminal-2.14.1.min.css"

    script src: "static/js/game.js"
    link rel: "stylesheet", href: "static/css/game.css"

    div id: "terminal"
