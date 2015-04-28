require "sitegen"

tools = require"sitegen.tools"

exec = (cmd) ->
  f = io.popen(cmd)
  with f\read "*a"
    f\close!

site = sitegen.create_site =>
  @title = "Sticky-Kit | jQuery plugin for sticky elements"
  @version = "1.1.2"

  @full_size = exec("du -bh www/src/jquery.sticky-kit.js | cut -f 1")\lower!
  @compressed_size = exec("du -bh www/src/jquery.sticky-kit.min.js | cut -f 1")\lower!

  deploy_to "leaf@leafo.net", "www/sticky-kit"

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
