document.addEventListener('turbolinks:load', function() {
  if ($('body.nodes.show').length) {
    new DradisDatatable('[data-behavior~=node-notes-table]');
    new DradisDatatable('[data-behavior~=node-evidence-table]');
  }
});
