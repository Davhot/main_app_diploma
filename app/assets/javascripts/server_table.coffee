server_table = ->
  if gon.server_main_staticstic_path
    $.ajax({url: gon.server_main_staticstic_path})

$ -> server_table()
