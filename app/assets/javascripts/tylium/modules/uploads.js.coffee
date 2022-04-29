document.addEventListener "turbolinks:load", ->
  if $('body.upload').length
    # Enable Ajax file uploads via 3rd party plugin
    $bar = $('.progress-bar');
    $percent = $('.percent');
    $status = $('#status');
    $('form#new_upload').ajaxForm({
      dataType: 'script'
      beforeSend: ->
          $status.empty();
          percentVal = '0%';
          $bar.width(percentVal)
          $bar.addClass('bg-primary')
          $percent.html(percentVal);
      uploadProgress: (event, position, total, percentComplete)->
          percentVal = percentComplete + '%';
          $bar.width(percentVal)
          $percent.html(percentVal);
          $percent.css('color', '#fff;')
      success: ->
          percentVal = '100%';
          $bar.width(percentVal)
          $bar.removeClass('bg-primary').addClass('bg-success')
          $percent.html(percentVal);
    });

    dropArea = $('.drag-area')
    dragText = $('.drag-area > .prompt')
    button =  $('.upload-input')
    input = $('.upload-file-input')
    # select files on button click
    button.on 'click', ->
      input.click();
    # add active class to drag area on drag enter
    dropArea.on 'dragover', (e) ->
      e.preventDefault()
      dropArea.addClass('active')
    # remove active class to drag area on drag leave
    dropArea.on 'dragleave', (e) ->
      e.preventDefault()
      dropArea.removeClass('active')
    # handle dropped files
    dropArea.on 'drop', (e) ->
      e.preventDefault()
      files = e.originalEvent.dataTransfer.files
      input.files = files
      processFiles(files)

    # on file select
    input.change (e) ->
      ConsoleUpdater.jobId = ConsoleUpdater.jobId + 1
      processFiles(e.target.files)

# detect plugin to use
processFiles = (files) ->
  i = 0;
  $('#selected-files').html('')
  while f = files[i]
    ((f, i) ->
      reader = new FileReader();
      reader.onloadend = (e) ->
        plugin = parseFile(e.target.result)
        status = if plugin == 'unknown' then 'Error' else 'Ready'
        badge_class = if plugin == 'unknown' then 'badge-danger' else 'badge-success'
        $('#selected-files').append("
          <li class='list-group-item d-flex justify-content-between align-items-center'>
          #{f.name}<code>#{plugin}</code> <span class='badge p-2 #{badge_class} '>#{status}</span> </li>
          ")
      reader.readAsText(f);
    ) files[i], i
    i++
# parse and search files
parseFile = (text) ->
  search = [
    {type: 'xml', keywords: [/Nessus/, /NessusClientData_v2/], plugin: 'Dradis::Plugins::Nessus'},
    {type: 'json', keywords: [/WPScan/], plugin: 'Dradis::Plugins::Wpscan'},
    {type: 'xml', keywords: [/nmap/], plugin: 'Dradis::Plugins::Nmap'}
  ]
  if validateData(text)
    plugin = 'unknown'
    for s in search
      if s.keywords.some((r) -> r.test text)
        plugin = s.plugin
        break
  else
    consoel.log('invalid data')
  return plugin

# determine data type before parsing XML or JSON
validateData = (data) ->
  if data.match(/^\{/)
    try
      JSON.parse(data)
      return 'json'
    catch e
      return false
  else if data.match(/^\</)
    try
      $.parseXML(data)
      return 'xml'
    catch e
      return false
  else
    return false