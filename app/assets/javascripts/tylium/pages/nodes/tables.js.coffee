document.addEventListener "turbolinks:load", ->
  if $('body.nodes.show').length

    new ItemsTable('#node-notes-table', 'note')
    new ItemsTable('#node-evidence-table', 'evidence')
