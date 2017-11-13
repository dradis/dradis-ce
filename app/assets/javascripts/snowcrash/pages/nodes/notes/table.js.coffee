document.addEventListener "turbolinks:load", ->
  if $('body.nodes.show').length

    new IndexTable('note')
