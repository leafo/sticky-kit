describe "sticky_kit", ->
  it "basic inline-block stick", (done) ->
    write_iframe("""
      <div class="stick_outer">
        <div class="left_cell" style="height: 500px"></div>
        <div class="right_cell"></div>
      </div>
      <script type="text/javascript">
        $(".right_cell").stick_in_parent()
      </script>
    """).then (f) =>
      cell = f.find(".right_cell")

      expect(cell.position().top).toBe 2

      scroll_to f, 1, =>
        expect(cell.position().top).toBe 2
        expect(cell.css("position")).toBe "static"

        scroll_to f, 200, =>
          expect(cell.position().top).toBe 0
          expect(cell.css("position")).toBe "fixed"

          scroll_to f, 480, =>
            expect(cell.position().top).toBe 460
            expect(cell.css("position")).toBe "absolute"
            done()


iframe_template = (content) -> """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <script src="../node_modules/jquery/dist/jquery.js"></script>
  <script src="sticky-kit.js"></script>

  <style type="text/css">
    body {
      margin: 0;
      padding: 0;
    }
    .stick_outer {
      border: 2px solid red;
      margin-bottom: 100%;
    }
    .stick_outer > * {
      vertical-align: top;
      display: inline-block;
      min-width: 40px;
      min-height: 40px;
      box-shadow: inset 0 0 0 2px rgba(255,255,255,0.5);
      background: blue;
    }
  </style>
</head>
<body>
#{content}
</body>
</html>
"""

write_iframe = (contents, opts={}) ->
  {
    width
    height
  } = opts

  width ?= 200
  height ?= 100

  drop = $ ".iframe_drop"
  frame = $ "<iframe></iframe>"

  frame.css {
    width: "#{width}px"
    height: "#{height}px"
  }

  frame.appendTo drop
  frame = frame[0]

  out = $.Deferred (d) =>
    frame.onload = =>
      d.resolve $(frame).contents(), frame

  frame.contentWindow.document.open()

  frame.contentWindow.onerror = (e) => expect(e).toBe null

  frame.contentWindow.document.write iframe_template contents
  frame.contentWindow.document.close()

  out

scroll_to = (f, p, callback) ->
  win = f[0].defaultView
  $(win).one "scroll", => callback()
  f.scrollTop(p)


