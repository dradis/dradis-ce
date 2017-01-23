//= require snowcrash/modules/issues/evidence
//= require snowcrash/modules/issues/importer
//= require snowcrash/modules/issues/table
//= require snowcrash/modules/issues/tag-input
//= require snowcrash/modules/issues/merging

jQuery ->
  if ($('body.issues').length)
    $('.import-toggle').click ->
      $this = $(this)
      $this.find('i').toggleClass('fa-chevron-down fa-chevron-up')
      $($this.data('target')).find("input[type='text']:first").focus()
