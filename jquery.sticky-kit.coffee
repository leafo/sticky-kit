###*
@license Sticky-kit v1.0.1 | WTFPL | Leaf Corcoran 2013 | http://leafo.net
###

$ = @jQuery

win = $ window
$.fn.stick_in_parent = (opts={}) ->
  { sticky_class, inner_scrolling, parent: parent_selector, offset_top } = opts
  offset_top ?= 0
  parent_selector ?= undefined
  inner_scrolling ?= true
  sticky_class ?= "is_stuck"

  for elm in @
    ((elm, padding_bottom, parent_top, parent_height, top, height) ->
      parent = elm.parent()
      parent = parent.closest(parent_selector) if parent_selector?
      throw "failed to find stick parent" unless parent.length

      recalc = ->
        border_top = parseInt parent.css("border-top-width"), 10
        padding_top = parseInt parent.css("padding-top"), 10
        padding_bottom = parseInt parent.css("padding-bottom"), 10

        parent_top = parent.offset().top + border_top + padding_top
        parent_height = parent.height()

        sizing_elm = if elm.is ".is_stuck"
          spacer
        else
          elm

        top = sizing_elm.offset().top - parseInt(sizing_elm.css("margin-top"), 10) - offset_top
        height = sizing_elm.outerHeight true

      recalc()
      return if height == parent_height

      # create a spacer
      float = elm.css "float"

      spacer = $("<div />").css({
        width: elm.outerWidth true
        height: height
        display: elm.css "display"
        "vertical-align": elm.css "vertical-align"
        float: float
      })

      fixed = false
      bottomed = false
      last_pos = undefined
      offset = offset_top
      reset_width = false

      tick = ->
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
              top: offset
            }).trigger("sticky_kit:unbottom")

          # unfixing
          if scroll < top
            fixed = false
            offset = offset_top

            if float == "left" || float == "right"
              elm.insertAfter spacer

            spacer.detach()
            css = {
              position: ""
              top: ""
            }
            css.width = "" if reset_width
            elm.css(css).removeClass(sticky_class).trigger("sticky_kit:unstick")

          # updated offset
          if inner_scrolling
            win_height = win.height()
            if height > win_height # bigger than viewport
              unless bottomed
                offset -= delta
                offset = Math.max win_height - height, offset
                offset = Math.min offset_top, offset

                if fixed
                  elm.css {
                    top: offset + "px"
                  }

        else
          # fixing
          if scroll > top
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

      recalc_and_tick = ->
        recalc()
        tick()

      detach = ->
        win.off "scroll", tick
        $(document.body).off "sticky_kit:recalc", recalc_and_tick
        elm.off "sticky_kit:detach", detach

        elm.css {
          position: ""
          bottom: ""
          top: ""
        }

        parent.position "position", ""

        if elm.is ".is_stuck"
          elm.insertAfter(spacer).removeClass "is_stuck"
          spacer.remove()

      win.on "scroll", tick
      $(document.body).on "sticky_kit:recalc", recalc
      elm.on "sticky_kit:detach", detach

      setTimeout tick, 0

    ) $ elm
  @


