
$ ->
  $("body").on "click", ".example_controls button", (e) =>
    $(e.currentTarget)
      .closest(".example").find("iframe")[0].contentWindow.scroll_it()

