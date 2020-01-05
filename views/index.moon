import Widget from require "lapis.html"

class extends Widget
  content: =>
    script src: "static/js/jquery/jquery.terminal-1.5.0.min.js"
    link rel: "stylesheet", href: "static/js/jquery/jquery.terminal-1.5.0.min.css"

    script src: "static/js/game.js"
    link rel: "stylesheet", href: "static/css/game.css"

    div id: "terminal"
