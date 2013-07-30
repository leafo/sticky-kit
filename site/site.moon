require "sitegen"

tools = require"sitegen.tools"

site = sitegen.create_site =>
  @title = "sticky-kit"

  scssphp = tools.system_command "pscss < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scssphp, "main.scss"
  build scssphp, "example.scss"

  build coffeescript, "main.coffee"
  build coffeescript, "example.coffee"

  add "index.html"
  add "examples/1.html", "examples/2.html", "examples/3.html",
    "examples/4.html", template: "example"

site\write!
