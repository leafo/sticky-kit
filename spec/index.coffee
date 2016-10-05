
at = Array
top = (el) -> el[0].getBoundingClientRect().top

describe "sticky columns", ->
  ["inline-block", "float"].forEach (type) =>
    describe type, ->
      [

        [
          "right stick"
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
          "left stick"
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
    }

    /* inline block */
    .stick_columns.inline-block .cell {
      vertical-align: top;
      display: inline-block;
    }

    /* float */
    .stick_columns.float {
      overflow: hidden;
    }

    .stick_columns.float .cell {
      float: left;
    }

    /* flexbox */
    .stick_columns.flexbox {
      display: flex;
      align-items: flex-start;
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

