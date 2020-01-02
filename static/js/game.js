$(function() {
  $("#terminal").terminal(function(command, term) {
    if (command == "") { return false; }

    Terminal.pause();
    $.post(location.origin + "/command", { command: command }).then(function(response) {
      Terminal.echo(response, {keepWords: true}).resume()
    })
  }, {
    prompt: "> ",
    greetings: "[[;lime;]Welcome. Type 'learn' to learn about Realms 2, and 'learn to login' when you're ready to make an account.]",
    exit: false,
    historySize: false
  })
})
