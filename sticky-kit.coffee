###*
@license Sticky-kit v1.1.4 | MIT | Leaf Corcoran 2015 | http://leafo.net
###

$ = window.jQuery

win = $ window
doc = $ document

$.fn.stick_in_parent = (opts={}) ->
  {
    sticky_class
    inner_scrolling
    recalc_every
    parent: parent_selector
    offset_top
    spacer: manual_spacer
    bottoming: enable_bottoming
  } = opts

  win_height = win.height()
  doc_height = doc.height()

  offset_top ?= 0
  parent_selector ?= undefined
  inner_scrolling ?= true
  sticky_class ?= "is_stuck"

  enable_bottoming = true unless enable_bottoming?

  # we need this because jquery's version (along with css()) rounds everything
  outer_width = (el) ->
    if window.getComputedStyle
      _el = el[0]
      computed = window.getComputedStyle el[0]

      w = parseFloat(computed.getPropertyValue("width")) + parseFloat(computed.getPropertyValue("margin-left")) + parseFloat(computed.getPropertyValue("margin-right"))

      if computed.getPropertyValue("box-sizing") != "border-box"
        w += parseFloat(computed.getPropertyValue("border-left-width")) + parseFloat(computed.getPropertyValue("border-right-width")) + parseFloat(computed.getPropertyValue("padding-left")) + parseFloat(computed.getPropertyValue("padding-right"))
      w
    else
      el.outerWidth true

  for elm in @
    ((elm, padding_bottom, parent_top, parent_height, top, height, el_float, detached) ->
      return if elm.data "sticky_kit"
      elm.data "sticky_kit", true

      last_scroll_height = doc_height

      parent = elm.parent()
      parent = parent.closest(parent_selector) if parent_selector?
      throw "failed to find stick parent" unless parent.length

      fixed = false
      bottomed = false
      spacer = if manual_spacer?
        manual_spacer && elm.closest manual_spacer
      else
        $("<div />")

      spacer.css('position', elm.css('position')) if spacer

      recalc = ->
        return if detached
        win_height = win.height();
        doc_height = doc.height();
        last_scroll_height = doc_height

        border_top = parseInt parent.css("border-top-width"), 10
        padding_top = parseInt parent.css("padding-top"), 10
        padding_bottom = parseInt parent.css("padding-bottom"), 10

        parent_top = parent.offset().top + border_top + padding_top
        parent_height = parent.height()

        if fixed
          fixed = false
          bottomed = false

          unless manual_spacer?
            elm.insertAfter(spacer)
            spacer.detach()

          elm.css({
            position: ""
            top: ""
            width: ""
            bottom: ""
          }).removeClass(sticky_class)

          restore = true

        top = elm.offset().top - (parseInt(elm.css("margin-top"), 10) or 0) - offset_top

        height = elm.outerHeight true

        el_float = elm.css "float"
        spacer.css({
          width: outer_width elm
          height: height
          display: elm.css "display"
          "vertical-align": elm.css "vertical-align"
          "float": el_float
        }) if spacer

        if restore
          tick()

      recalc()
      return if height == parent_height

      last_pos = undefined
      offset = offset_top

      recalc_counter = recalc_every

      tick = ->
        return if detached
        recalced = false

        if recalc_counter?
          recalc_counter -= 1
          if recalc_counter <= 0
            recalc_counter = recalc_every
            recalc()
            recalced = true

        if !recalced && doc_height != last_scroll_height
          recalc()
          recalced = true

        scroll = win.scrollTop()
        if last_pos?
          delta = scroll - last_pos
        last_pos = scroll

        if fixed
          if enable_bottoming
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

            unless manual_spacer?
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
            if height + offset_top > win_height # bigger than viewport
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

            elm.css(css).addClass(sticky_class)

            unless manual_spacer?
              elm.after(spacer)

              if el_float == "left" || el_float == "right"
                spacer.append elm

            elm.trigger("sticky_kit:stick")

        # this is down here because we can fix and bottom in same step when
        # scrolling huge
        if fixed && enable_bottoming
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
        detached = true
        win.off "touchmove", tick
        win.off "scroll", tick
        win.off "resize", recalc_and_tick

        $(document.body).off "sticky_kit:recalc", recalc_and_tick
        elm.off "sticky_kit:detach", detach
        elm.removeData "sticky_kit"

        elm.css {
          position: ""
          bottom: ""
          top: ""
          width: ""
        }

        parent.position "position", ""

        if fixed
          unless manual_spacer?
            if el_float == "left" || el_float == "right"
              elm.insertAfter spacer
            spacer.remove()

          elm.removeClass sticky_class

      win.on "touchmove", tick
      win.on "scroll", tick
      win.on "resize", recalc_and_tick
      $(document.body).on "sticky_kit:recalc", recalc_and_tick
      elm.on "sticky_kit:detach", detach

      setTimeout tick, 0

    ) $ elm
  @


