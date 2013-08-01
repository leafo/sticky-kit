
# make it sticky
$ ->
  $("[data-sticky_column]").stick_in_parent(parent: "[data-sticky_parent]")

window.scroll_it = ->
  max = $(document).height() - $(window).height()
  $("body,html")
    .stop(true)
    .animate({ scrollTop: max }, max*3)
    .delay(100)
    .animate({ scrollTop: 0 }, max*3)

window.scroll_it_wobble = ->
  max = $(document).height() - $(window).height()
  third = Math.floor max / 3

  $("body,html")
    .stop(true)
    .animate({ scrollTop: third * 2 }, max*3)
    .delay(100)
    .animate({ scrollTop: third }, max*3)
    .delay(100)
    .animate({ scrollTop: max }, max*3)
    .delay(100)
    .animate({ scrollTop: 0 }, max*3)


