class @SelectTagDropdown
  constructor: (@$target) ->
    @init()

  init: ->
   

document.addEventListener "turbolinks:load", ->
  $.fn.selectpicker.Constructor.BootstrapVersion = '4';
  $('#issue_tag_list').selectpicker liveSearch: true
  $(document).on 'loaded.bs.select', '#issue_tag_list', (e) ->
    $(e.currentTarget).siblings('.dropdown-menu').on 'keyup', '.bs-searchbox input', (ie) ->
      searchPhrase = $(this).val()
      searchList = $(this).parent().next("#bs-select-1").children(".dropdown-menu").children('li')
      if $(searchList[0]).hasClass('no-results')
        searchList[0].innerHTML = "<span  class='new-tag text-muted'>No results found add <span class='badge'>#{searchPhrase}</span> ?</span>"
  $(document).on 'click', '.new-tag', (e) ->
    console.log("add new tag")
    url = $("#issue_tag_list").data("url")
    $.ajax
      url: url
      data: { "tag[tag_name]": $(this).children('.badge').text(), "tag[color]": "#6c777f" }
      type: 'POST'
      dataType: "json"
      success: (data) ->
        option = "<option data-content=\"<span class='badge' style='color:#fff; background-color:"+data.color+"'>"+data.display_name+"<\/span>\" value=\""+data.name+"\">"+data.display_name+"<\/option>";
        $('#issue_tag_list').append(option);
        $('#issue_tag_list').selectpicker("refresh");
        $('#issue_tag_list').selectpicker('val', data.name);
      error: ->