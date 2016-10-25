
animate_scroll = false
at = Array
top = (el) -> el[0].getBoundingClientRect().top
smoothstep = (t) -> t*t*t*(t*(t*6 - 15) + 10)

describe "sticky columns", ->
  ["inline-block", "float"].forEach (type) =>
    describe type, ->
      [

        [
          "right stick, default align"
          """
            <div class="stick_columns #{type}">
              <div class="cell static_cell" style="height: 500px"></div>
              <div class="cell stick_cell"></div>
            </div>
            <script type="text/javascript">
              $(".stick_cell").stick_in_parent()
            </script>
          """
        ]

        [
          "left stick, default align"
          """
            <div class="stick_columns #{type}">
              <div class="cell stick_cell"></div>
              <div class="cell static_cell" style="height: 500px"></div>
            </div>
            <script type="text/javascript">
              $(".stick_cell").stick_in_parent()
            </script>
          """
        ]

        [
          "right stick, right align"
          """
            <div class="stick_columns #{type} align_right">
              <div class="cell static_cell" style="height: 500px"></div>
              <div class="cell stick_cell"></div>
            </div>
            <script type="text/javascript">
              $(".stick_cell").stick_in_parent()
            </script>
          """
        ]

        [
          "left stick, right align"
          """
            <div class="stick_columns #{type} align_right">
              <div class="cell stick_cell"></div>
              <div class="cell static_cell" style="height: 500px"></div>
            </div>
            <script type="text/javascript">
              $(".stick_cell").stick_in_parent()
            </script>
          """
        ]

      ].forEach ([name, html]) =>
        it name, (done) ->
          write_iframe(html).then (f) =>
            cell = f.find(".stick_cell")

            expect(top cell).toBe 2
            expect(cell.css("position")).toBe "static"
            expect(cell.is(".is_stuck")).toBe false

            scroll_each f, done, [
              at 1, =>
                expect(top cell).toBe 1
                expect(cell.css("position")).toBe "static"
                expect(cell.is(".is_stuck")).toBe false

              at 200, =>
                expect(top cell).toBe 0
                expect(cell.css("position")).toBe "fixed"
                expect(cell.css("top")).toBe "0px"
                expect(cell.is(".is_stuck")).toBe true

              at 480, =>
                expect(top cell).toBe -18 # 500 - 480 - 2
                expect(cell.css("position")).toBe "absolute"
                expect(cell.is(".is_stuck")).toBe true

              at 200, =>
                expect(top cell).toBe 0
                expect(cell.css("position")).toBe "fixed"
                expect(cell.css("top")).toBe "0px"
                expect(cell.is(".is_stuck")).toBe true

              at 0, =>
                expect(top cell).toBe 2
                expect(cell.css("position")).toBe "static"
                expect(cell.is(".is_stuck")).toBe false
            ]

      it "multiple", (done) ->
        write_iframe("""
          <div class="stick_columns #{type}">
            <div class="cell stick_cell a"></div>
            <div class="cell stick_cell b" style="height: 75vh"></div>
            <div class="cell static_cell" style="height: 500px"></div>
          </div>
          <script type="text/javascript">
            $(".stick_cell").stick_in_parent()
          </script>
        """).then (f) =>
          a = f.find(".stick_cell.a")
          b = f.find(".stick_cell.b")

          scroll_each f, done, [
            at 40, =>
              [a,b].forEach (el) =>
                expect(top el).toBe 0
                expect(el.css("position")).toBe "fixed"
                expect(el.css("top")).toBe "0px"

            at 430, =>
              expect(top a).toBe 0
              expect(a.css("position")).toBe "fixed"
              expect(a.css("top")).toBe "0px"

              # b has bottomed
              expect(top b).toBe -3
              expect(b.css("position")).toBe "absolute"
              expect(b.css("bottom")).toBe "0px"

            at 485, =>
              # both are bottomed
              [a, b].forEach (el) =>
                expect(el.css("position")).toBe "absolute"
                expect(el.css("bottom")).toBe "0px"

              expect(top a).toBe -23
              expect(top b).toBe -58

            at 440, =>
              expect(top a).toBe 0
              expect(a.css("position")).toBe "fixed"
              expect(a.css("top")).toBe "0px"

              # b has bottomed
              expect(top b).toBe -13
              expect(b.css("position")).toBe "absolute"
              expect(b.css("bottom")).toBe "0px"

            at 0, =>
              [a,b].forEach (el) =>
                expect(top el).toBe 2
                expect(el.css("position")).toBe "static"
                expect(el.css("top")).toBe "auto"
          ]

      it "padding, margin, border", (done) ->
        write_iframe("""
          <div class="stick_columns #{type}" style="border-width: 8px; padding: 8px; margin: 8px; background: rgba(255,0,0,0.1); margin-bottom: 500px">
            <div class="cell static_cell" style="height: 500px"></div>
            <div class="cell stick_cell"></div>
          </div>
          <script type="text/javascript">
            $(".stick_cell").stick_in_parent()
          </script>
        """).then (f) =>
          cell = f.find(".stick_cell")

          expect(top cell).toBe 24
          expect(cell.css("position")).toBe "static"
          expect(cell.is(".is_stuck")).toBe false

          scroll_each f, done, [
            at 5, =>
              expect(top cell).toBe 19
              expect(cell.css("position")).toBe "static"
              expect(cell.is(".is_stuck")).toBe false

            at 200, =>
              expect(top cell).toBe 0
              expect(cell.css("position")).toBe "fixed"
              expect(cell.css("top")).toBe "0px"
              expect(cell.is(".is_stuck")).toBe true

            at 490, =>
              expect(top cell).toBe -6
              expect(cell.css("position")).toBe "absolute"
              expect(cell.is(".is_stuck")).toBe true

            at 200, =>
              expect(top cell).toBe 0
              expect(cell.css("position")).toBe "fixed"
              expect(cell.css("top")).toBe "0px"
              expect(cell.is(".is_stuck")).toBe true

            at 0, =>
              expect(top cell).toBe 24
              expect(cell.css("position")).toBe "static"
              expect(cell.is(".is_stuck")).toBe false
          ]


      it "inner scrolling", (done) ->
        write_iframe("""
          <div class="stick_columns #{type}">
            <div class="cell stick_cell" style="height: 200px"></div>
            <div class="cell static_cell" style="height: 500px"></div>
          </div>
          <script type="text/javascript">
            $(".stick_cell").stick_in_parent()
          </script>
        """).then (f) =>
          cell = f.find(".stick_cell")

          expect(top cell).toBe 2
          expect(cell.css("position")).toBe "static"
          expect(cell.is(".is_stuck")).toBe false

          # f.on "scroll", => console.warn f.scrollTop(), top cell

          scroll_each f, done, [
            # partially scrolled, stuck
            at 50, =>
              expect(top cell).toBe 0
              expect(cell.css("position")).toBe "fixed"
              expect(cell.is(".is_stuck")).toBe true

            # bottomed to viewport
            at 170, =>
              expect(top cell).toBe -100
              expect(cell.css("position")).toBe "fixed"
              expect(cell.is(".is_stuck")).toBe true

            # bottomed in container
            at 410, =>
              expect(top cell).toBe -108
              expect(cell.css("position")).toBe "absolute"
              expect(cell.is(".is_stuck")).toBe true

            # partially scrolled up
            at 350, =>
              expect(top cell).toBe -40
              expect(cell.css("position")).toBe "fixed"
              expect(cell.is(".is_stuck")).toBe true

            # topped in viewport
            at 230, =>
              expect(top cell).toBe 0
              expect(cell.css("position")).toBe "fixed"
              expect(cell.is(".is_stuck")).toBe true

            # topped in container
            at 0, =>
              expect(top cell).toBe 2
              expect(cell.css("position")).toBe "static"
              expect(cell.is(".is_stuck")).toBe false
          ]


      it "recalc", (done) ->
        write_iframe("""
          <div class="stick_columns #{type}">
            <div class="cell static_cell" style="height: 500px"></div>
            <div class="cell stick_cell"></div>
          </div>
          <script type="text/javascript">
            $(".stick_cell").stick_in_parent()
            window.sticky_kit_recalc = function() {
              $(document.body).trigger("sticky_kit:recalc")
            }
          </script>
        """).then (f) =>
          cell = f.find(".stick_cell")
          tall = f.find(".static_cell")
          scroll_to f, 125, =>
            # change the page in a way that sticky kit won't notice
            tall.css height: "150vh"

            # element is still incorrectly positioned
            expect(top cell).toBe 0
            expect(cell.css("position")).toBe "fixed"
            expect(cell.css("top")).toBe "0px"

            # fix it
            cell.trigger("sticky_kit:recalc")

            # check repiared state
            expect(top cell).toBe -13
            expect(cell.css("position")).toBe "absolute"
            expect(cell.css("bottom")).toBe "0px"

            done()


  describe "flexbox", ->
    # TODO:
    ###
    it "right stick", (done) ->
      write_iframe("""
        <div class="stick_columns flexbox">
          <div class="cell static_cell" style="height: 500px"></div>
          <div class="cell stick_cell"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent();
        </script>
      """).then (f) =>
        expect(1).toBe 1
        done()
    ###

  describe "header", ->
    it "sticks a header row", (done) ->
      write_iframe("""
        <div class="stick_header">
          <div class="stick_cell header"></div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent()
        </script>
      """).then (f) =>
        cell = f.find(".stick_cell")

        # f.on "scroll", => console.warn f.scrollTop(), top cell

        expect(top cell).toBe 2
        expect(cell.css("position")).toBe "static"
        expect(cell.css("top")).toBe "auto"
        expect(cell.is(".is_stuck")).toBe false

        scroll_each f, done, [
          at 20, =>
            expect(top cell).toBe 0
            expect(cell.css("position")).toBe "fixed"
            expect(cell.css("top")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true

          at 90, =>
            expect(top cell).toBe 0
            expect(cell.css("position")).toBe "fixed"
            expect(cell.css("top")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true

          at 125, =>
            expect(top cell).toBe -23
            expect(cell.css("position")).toBe "absolute"
            expect(cell.css("top")).toBe "100px"
            expect(cell.css("bottom")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true

          at 0, =>
            expect(top cell).toBe 2
            expect(cell.css("position")).toBe "static"
            expect(cell.css("top")).toBe "auto"
            expect(cell.is(".is_stuck")).toBe false
        ]


    it "sticks with custom spacer", (done) ->
      write_iframe("""
        <div class="stick_header">
          <div class="spacer">
            <div class="stick_cell header"></div>
          </div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent({
            parent: ".stick_header",
            spacer: ".spacer",
          })
        </script>
      """).then (f) =>
        cell = f.find(".stick_cell")

        expect(top cell).toBe 7
        expect(cell.css("position")).toBe "static"
        expect(cell.css("top")).toBe "auto"
        expect(cell.is(".is_stuck")).toBe false

        scroll_each f, done, [
          at 20, =>
            expect(top cell).toBe 0
            expect(cell.css("position")).toBe "fixed"
            expect(cell.css("top")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true

          at 100, =>
            expect(top cell).toBe 0
            expect(cell.css("position")).toBe "fixed"
            expect(cell.css("top")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true

          at 125, =>
            expect(top cell).toBe -13
            expect(cell.css("position")).toBe "absolute"
            expect(cell.css("bottom")).toBe "0px"
            expect(cell.is(".is_stuck")).toBe true
        ]



  describe "options", ->
    it "uses custom sticky class", (done) ->
      write_iframe("""
        <div class="stick_header">
          <div class="stick_cell header"></div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent({sticky_class: "really_stick"})
        </script>

      """).then (f) ->
        cell = f.find(".stick_cell")

        scroll_each f, done, [
          at 20, =>
            expect(cell.is(".really_stick")).toBe true
        ]

    it "disables bottoming", (done) ->
      write_iframe("""
        <div class="stick_header">
          <div class="stick_cell header"></div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent({bottoming: false})
        </script>

      """).then (f) ->
        cell = f.find(".stick_cell")

        # f.on "scroll", => console.warn f.scrollTop(), top cell

        scroll_each f, done, [
          at 2, =>
            expect(top cell).toBe 0
            expect(cell.is(".is_stuck")).toBe false

          at 62, =>
            expect(top cell).toBe 0
            expect(cell.is(".is_stuck")).toBe true

          at 180, =>
            expect(top cell).toBe 0
            expect(cell.is(".is_stuck")).toBe true

          at 62, =>
            expect(top cell).toBe 0
            expect(cell.is(".is_stuck")).toBe true

          at 0, =>
            expect(top cell).toBe 2
            expect(cell.is(".is_stuck")).toBe false
        ]

    it "uses offset top", (done) ->
      write_iframe("""
        <div class="stick_header" style="margin-top: 20px">
          <div class="stick_cell header"></div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent({offset_top: 10})
        </script>

      """).then (f) ->
        cell = f.find(".stick_cell")

        # f.on "scroll", => console.warn f.scrollTop(), top cell

        scroll_each f, done, [
          at 5, =>
            expect(top cell).toBe 17
            expect(cell.is(".is_stuck")).toBe false

          at 15, =>
            expect(top cell).toBe 10
            expect(cell.is(".is_stuck")).toBe true

          at 40, =>
            expect(top cell).toBe 10
            expect(cell.is(".is_stuck")).toBe true

          at 125, =>
            expect(top cell).toBe -3
            expect(cell.is(".is_stuck")).toBe true

          at 15, =>
            expect(top cell).toBe 10
            expect(cell.is(".is_stuck")).toBe true

          at 0, =>
            expect(top cell).toBe 22
            expect(cell.is(".is_stuck")).toBe false
        ]


  describe "events", ->
    it "detects events when scrolling sticky header", (done) ->
      write_iframe("""
        <div class="stick_header">
          <div class="stick_cell header"></div>
          <div class="stick_body"></div>
        </div>
        <script type="text/javascript">
          $(".stick_cell").stick_in_parent()
        </script>
      """).then (f) =>
        cell = f.find(".stick_cell")
        event_log = []

        f.on "sticky_kit:stick", (e) => event_log.push "stick"
        f.on "sticky_kit:unstick", (e) => event_log.push "unstick"
        f.on "sticky_kit:bottom", (e) => event_log.push "bottom"
        f.on "sticky_kit:unbottom", (e) => event_log.push "unbottom"


        scroll_each f, done, [
          at 1, =>
            expect(event_log).toEqual []

          at 20, =>
            expect(event_log).toEqual ["stick"]

          at 1, =>
            expect(event_log).toEqual ["stick", "unstick"]
            event_log = []

          at 20, =>
            expect(event_log).toEqual ["stick"]

          at 90, =>
            expect(event_log).toEqual ["stick"]

          at 125, =>
            expect(event_log).toEqual ["stick", "bottom"]

          at 145, =>
            expect(event_log).toEqual ["stick", "bottom"]

          at 20, =>
            expect(event_log).toEqual ["stick", "bottom", "unbottom"]

          at 0, =>
            expect(event_log).toEqual ["stick", "bottom", "unbottom", "unstick"]

        ]


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

    .stick_columns {
      border: 2px solid red;
      margin-bottom: 100%;
    }

    .stick_columns .cell {
      margin-right: 5px;
      width: 40px;
      height: 40px;
      box-shadow: inset 0 0 0 4px rgba(255,255,255,0.5);
      background: blue;
      background-image: linear-gradient(0deg, rgba(255, 255, 255, .2) 50%, transparent 50%, transparent);
      background-size: 20px 20px;
    }

    /* inline block */
    .stick_columns.inline-block .cell {
      vertical-align: top;
      display: inline-block;
    }

    .stick_columns.inline-block.align_right {
      text-align: right;
    }

    /* float */
    .stick_columns.float {
      overflow: hidden;
    }

    .stick_columns.float .cell {
      float: left;
    }

    .stick_columns.float.align_right .cell {
      float: right;
    }


    /* flexbox */
    .stick_columns.flexbox {
      display: flex;
      align-items: flex-start;
    }

    /* header */
    .stick_header {
      border: 2px solid red;
      margin-bottom: 100%;
    }

    .stick_header .stick_body {
      background: rgba(255,0,0,0.1);
      min-height: 100vh;
    }

    .stick_header .spacer {
      border: 5px solid green;
    }

    .stick_header .header {
      height: 40px;
      box-shadow: inset 0 0 0 4px rgba(255,255,255,0.5);
      background: blue;
      background-image: linear-gradient(0deg, rgba(255, 255, 255, .2) 50%, transparent 50%, transparent);
      background-size: 20px 20px;
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
      contents = $(frame).contents()
      # switch to inside jquery
      contents = frame.contentWindow.$ contents
      d.resolve contents, frame

  frame.contentWindow.document.open()

  frame.contentWindow.onerror = (e) => expect(e).toBe null

  frame.contentWindow.document.write iframe_template contents
  frame.contentWindow.document.close()

  out

animate = (a, b, duration, callback) ->
  start = window.performance.now()
  tick = ->
    window.requestAnimationFrame ->
      now = window.performance.now()
      p = smoothstep Math.min 1, (now - start) / duration
      callback p * (b - a) + a, p
      if p < 1
        tick()

  tick()

scroll_to = (f, position, callback) ->
  if animate_scroll
    start_position = f.scrollTop()
    space = Math.abs position - start_position

    animate start_position, position, space, (scroll, p) ->
      f.scrollTop Math.floor scroll
      if p == 1
        setTimeout ->
          callback()
        , 50
  else
    win = f[0].defaultView
    $(win).one "scroll", => callback()
    f.scrollTop position

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

