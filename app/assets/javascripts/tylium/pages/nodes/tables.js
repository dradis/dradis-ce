document.addEventListener('turbolinks:load', function() {
  if ($('body.nodes.show').length) {
    new DradisDatatable('#node-notes-table');
    new DradisDatatable('#node-evidence-table');
  }
});
