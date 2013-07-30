###*
@license WTFPL | Leaf Corcoran 2013 | http://leafo.net
###

$ = @jQuery

win = $ window
$.fn.stick_in_parent = (parent_selector, opts={}) ->
  if $.isPlainObject parent_selector
    opts = parent_selector
    parent_selector = undefined

  { sticky_class, inner_scrolling } = opts
  inner_scrolling ?= true
  sticky_class ?= "is_stuck"

  for elm in @
    ((elm, padding_bottom, parent_top, parent_height, height) ->
      parent = elm.parent()
      parent = parent.closest(parent_selector) if parent_selector?

      recalc = ->
        border_top = parseInt parent.css("border-top-width"), 10
        padding_top = parseInt parent.css("padding-top"), 10
        padding_bottom = parseInt parent.css("padding-bottom")

        parent_top = parent.offset().top + border_top + padding_top
        parent_height = parent.height()

        height = elm.outerHeight true

      recalc()
      return if height == parent_height
      parent.on "sticky_kit:recalc", recalc

      # create a spacer
      float = elm.css "float"

      spacer = $("<div />").css({
        width: elm.outerWidth true
        height: height
        display: elm.css "display"
        float: float
      })

      fixed = false
      bottomed = false
      last_pos = undefined
      offset = 0
      reset_width = false

      win.on "scroll", (e) ->
        scroll = win.scrollTop()
        if last_pos?
          delta = scroll - last_pos
        last_pos = scroll

        if fixed
          will_bottom = scroll + height + offset > parent_height + parent_top

          # unbottom
          if bottomed && !will_bottom
            bottomed = false
            elm.css({
              position: "fixed"
              bottom: ""
              top: 0
            }).trigger("sticky_kit:unbottom")

          # unfixing
          if scroll < parent_top
            fixed = false
            offset = 0

            if float == "left" || float == "right"
              elm.insertAfter spacer

            spacer.detach()
            css = {
              position: ""
            }
            css.width = "" if reset_width
            elm.css(css).removeClass(sticky_class).trigger("sticky_kit:unstick")

          # updated offset
          if inner_scrolling
            win_height = win.height()
            if height > win_height # bigger than viewport
              unless bottomed
                offset -= delta
                before = offset
                offset = Math.max win_height - height, offset
                offset = Math.min 0, offset

                elm.css {
                  top: offset + "px"
                }

        else
          # fixing
          if scroll > parent_top
            fixed = true
            css = {
              position: "fixed"
              top: offset
            }

            if float == "none" && elm.css("display") == "block"
              css.width = elm.width() + "px"
              reset_width = true

            elm.css(css).addClass(sticky_class).after(spacer)

            if float == "left" || float == "right"
              spacer.append elm

            elm.trigger("sticky_kit:stick")

        # this is down here because we can fix and bottom in same step when
        # scrolling huge
        if fixed
          will_bottom ?= scroll + height + offset > parent_height + parent_top

          # bottomed
          if !bottomed && will_bottom
            # bottomed out
            bottomed = true
            if parent.css("position") == "static"
              parent.css {
                position: "relative"
              }

            elm.css({
              position: "absolute"
              bottom: padding_bottom
              top: ""
            }).trigger("sticky_kit:bottom")
    ) $ elm
  @


