nginx_graphic = ->
  if gon.nginx_load_graph_path
    $.ajax({url: gon.nginx_load_graph_path})
  $(".nginx-form-filter").change ->
    $.ajax(
      url: gon.nginx_load_graph_path
      data: $(".nginx-form-filter").serialize()
      beforeSend: ->
        $(".nginx-form-filter .nginx-form-filter-field").attr("disabled", true)
        $(".nginx-form-filter-field").addClass("disabled")
    ).done( ->
      $(".nginx-form-filter .nginx-form-filter-field").removeAttr("disabled")
      $(".nginx-form-filter-field").removeClass("disabled")
    ).fail( ->
      alert("Данные не отправлены")
    )

$ -> nginx_graphic()
