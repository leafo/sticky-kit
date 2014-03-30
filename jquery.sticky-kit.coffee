###*
@license Sticky-kit v1.0.4 | WTFPL | Leaf Corcoran 2014 | http://leafo.net
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
    ((elm, padding_bottom, parent_top, parent_height, top, height, el_float) ->
      return if elm.data "sticky_kit"
      elm.data "sticky_kit", true

      parent = elm.parent()
      parent = parent.closest(parent_selector) if parent_selector?
      throw "failed to find stick parent" unless parent.length

      fixed = false
      bottomed = false
      spacer = $("<div />")
      spacer.css('position', elm.css('position'))

      recalc = ->
        border_top = parseInt parent.css("border-top-width"), 10
        padding_top = parseInt parent.css("padding-top"), 10
        padding_bottom = parseInt parent.css("padding-bottom"), 10

        parent_top = parent.offset().top + border_top + padding_top
        parent_height = parent.height()

        restore = if fixed
          fixed = false
          bottomed = false
          elm.insertAfter(spacer).css {
            position: ""
            top: ""
            width: ""
            bottom: ""
          }
          spacer.detach()
          true

        top = elm.offset().top - parseInt(elm.css("margin-top"), 10) - offset_top

        height = elm.outerHeight true

        el_float = elm.css "float"
        spacer.css({
          width: elm.outerWidth true
          height: height
          display: elm.css "display"
          "vertical-align": elm.css "vertical-align"
          "float": el_float
        })

        if restore
          tick()

      recalc()
      return if height == parent_height

      last_pos = undefined
      offset = offset_top

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

            if el_float == "left" || el_float == "right"
              elm.insertAfter spacer

            spacer.detach()
            css = {
              position: ""
              width: ""
              top: ""
            }
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

            css.width = if elm.css("box-sizing") == "border-box"
              elm.outerWidth() + "px"
            else
              elm.width() + "px"

            elm.css(css).addClass(sticky_class).after(spacer)

            if el_float == "left" || el_float == "right"
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
              top: "auto"
            }).trigger("sticky_kit:bottom")

      recalc_and_tick = ->
        recalc()
        tick()

      detach = ->
        win.off "scroll", tick
        $(document.body).off "sticky_kit:recalc", recalc_and_tick
        elm.off "sticky_kit:detach", detach
        elm.removeData "sticky_kit"

        elm.css {
          position: ""
          bottom: ""
          top: ""
        }

        parent.position "position", ""

        if fixed
          elm.insertAfter(spacer).removeClass sticky_class
          spacer.remove()

      win.on "touchmove", tick
      win.on "scroll", tick
      win.on "resize", recalc_and_tick
      $(document.body).on "sticky_kit:recalc", recalc_and_tick
      elm.on "sticky_kit:detach", detach

      setTimeout tick, 0

    ) $ elm
  @


