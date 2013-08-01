
# make it sticky
$ ->
  $("[data-sticky_column]").stick_in_parent(parent: "[data-sticky_parent]")


reset_scroll = ->
  scroller = $("body,html")
  scroller.stop(true)

  if $(window).scrollTop() != 0
    scroller.animate({ scrollTop: 0}, "fast")

  scroller

window.scroll_it = ->
  max = $(document).height() - $(window).height()
  reset_scroll()
    .animate({ scrollTop: max }, max*3)
    .delay(100)
    .animate({ scrollTop: 0 }, max*3)

window.scroll_it_wobble = ->
  max = $(document).height() - $(window).height()
  third = Math.floor max / 3
  reset_scroll()
    .animate({ scrollTop: third * 2 }, max*3)
    .delay(100)
    .animate({ scrollTop: third }, max*3)
    .delay(100)
    .animate({ scrollTop: max }, max*3)
    .delay(100)
    .animate({ scrollTop: 0 }, max*3)


$(window).on "resize", (e) =>
  $(document.body).trigger("sticky_kit:recalc")
