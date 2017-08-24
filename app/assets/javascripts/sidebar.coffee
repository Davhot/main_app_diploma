ready = ->
  $("#sidebar-toggle").on 'click', ->
    id=$(this).children('.sidebar-toggle').attr 'href'
    $(id).toggleClass 'toggled'
    false
togglef = ->
  $(".with-subitems").on 'click', ->
    $(this).parent().children(".subitems").toggle(300)
    false

$(document).on 'page:load', ready
$(document).ready ready

$(document).on 'page:load', togglef
$(document).ready togglef
