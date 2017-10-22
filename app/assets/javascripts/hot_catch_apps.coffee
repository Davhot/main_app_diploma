apps_functions = ->
  link_app()
  toggle_errors()
  # $('#myModal').modal()

$(document).on 'turbolinks:load', apps_functions

# Переход по ссылке из data-link строки таблицы
link_app = ->
  $("tr[data-link]").click ->
    window.location = $(this).data("link")

toggle_errors = ->
  # $("#er-1").toggle(300)
  $("table[data-toggle-error] td:nth-child(2)").click ->
    id = $(this).parent().parent().parent().data("toggle-error")
    $(id).toggle(300)
