
at = Array
top = (el) -> el[0].getBoundingClientRect().top

describe "sticky_kit", ->
  describe "inline-block", ->
    test_frame = (f, done) ->
      cell = f.find(".stick_cell")

      expect(top cell).toBe 2
      expect(cell.css("position")).toBe "static"

      scroll_each f, done, [
        at 1, =>
          expect(top cell).toBe 1
          expect(cell.css("position")).toBe "static"

        at 200, =>
          expect(top cell).toBe 0
          expect(cell.css("position")).toBe "fixed"
          expect(cell.css("top")).toBe "0px"

        at 480, =>
          expect(top cell).toBe -18 # 500 - 480 - 2
          expect(cell.css("position")).toBe "absolute"

        at 200, =>
          expect(top cell).toBe 0
          expect(cell.css("position")).toBe "fixed"
          expect(cell.css("top")).toBe "0px"

        at 0, =>
          expect(top cell).toBe 2
          expect(cell.css("position")).toBe "static"
      ]


    it "right stick", (done) ->
      write_iframe("""
        <div class="stick_outer">
          <div class="static_cell" style="height: 500vh"></div>
          <div class="stick_cell"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent()
        </script>
      """).then (f) => test_frame f, done

    it "left stick", (done) ->
      write_iframe("""
        <div class="stick_outer">
          <div class="stick_cell"></div>
          <div class="static_cell" style="height: 500px"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent()
        </script>
      """).then (f) => test_frame f, done

  describe "float", ->

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
  drop.html ""

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

scroll_each = (f, done, points) ->
  scroll_to_next = ->
    next = points.shift()
    if next
      scroll_to f, next[0], ->
        next[1]?()
        scroll_to_next()
    else
      done()

  scroll_to_next()

