# Переход по ссылке из data-link строки таблицы
link_app = ->
  $("tr[data-link]").click ->
    window.location = $(this).data("link")

toggle_errors = ->
  # $("#er-1").toggle(300)
  $("table[data-toggle-error]").click ->
    id = $(this).data("toggle-error")
    $(id).toggle(300)

apps_functions = ->
  link_app()
  toggle_errors()

$(document).on 'page:load', apps_functions
$(document).ready apps_functions
