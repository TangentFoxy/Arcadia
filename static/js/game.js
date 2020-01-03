$(function() {
  $("#terminal").terminal(function(command, term) {
    if (command == "") { return false; }

    term.pause();

    // $.post(location.origin + "/command", { command: command }).then(function(response) {
    //   term.echo(response, {keepWords: true}).resume()
    // })
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
    greetings: "[[;lime;]Welcome. Type 'learn' to learn about Realms 2, and 'learn to login' when you're ready to make an account.]",
    exit: false,
    historySize: false
  })
})
