require "sitegen"

tools = require"sitegen.tools"

exec = (cmd) ->
  f = io.popen(cmd)
  with f\read "*a"
    f\close!

sitegen.create =>
  @title = "Sticky-Kit | jQuery plugin for sticky elements"
  @version = exec("git tag | tail -1")\lower!

  @full_size = exec("du -bh www/src/sticky-kit.js | cut -f 1")\lower!
  @compressed_size = exec("du -bh www/src/sticky-kit.min.js | cut -f 1")\lower!

  deploy_to "leaf@leafo.net", "www/sticky-kit"

  scss = tools.system_command "sassc -I scss < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scss, "main.scss"
  build scss, "example.scss"

  build coffeescript, "main.coffee"
  build coffeescript, "example.coffee"

  add "index.html"
  add "examples/1.html", "examples/2.html", "examples/3.html",
    "examples/4.html", template: "example"
