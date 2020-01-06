$(function() {
  $("#terminal").terminal(function(command, term) {
    if (command == "") { return false; }

    term.pause();

    $.ajax({
      type: "POST",
      url: location.origin + "/command",
      data: { command: command },
      complete: function(res) {
        term.echo(res.responseText, {keepWords: true}).resume()
      }
    })
  }, {
    prompt: "> ",
    greetings: "[[;lime;]Welcome. Type 'learn' and hit enter if you need help.]",
    exit: false,
    historySize: false
  })
})
