html = require "lapis.html"

class extends html.Widget
  content: =>
    html_5 ->
      head -> title "Realms 2"
      body ->
        script src: "static/js/jquery-3.2.1.min.js"

        noscript "This game requies JavaScript."

        div -> @content_for "inner"
