
$ ->
  $("body").on "click", ".example_controls button", (e) =>
    $(e.currentTarget)
      .closest(".example").find("iframe")[0].contentWindow.scroll_it()


  $(".nav").stick_in_parent().on("sticky_kit:stick", (e) =>
    setTimeout =>
      $(e.target).addClass "show_hidden"
    , 0
  ).on("sticky_kit:unstick", (e) =>
    setTimeout =>
      $(e.target).removeClass "show_hidden"
    , 0
  )
