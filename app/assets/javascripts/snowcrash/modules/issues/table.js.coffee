#= require snowcrash/modules/table

jQuery ->
  if $('body.issues.index').length
    new IndexTable('issue')
