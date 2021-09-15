(function($, window){
  function initBehaviors(parentElement) {
    //Activate jQuery.Textile
    $(parentElement).find('.textile').textile();

    // Activate DataTables
    $(parentElement).find('[data-behavior~=dradis-datatable]').each(function() {
      new DradisDatatable(this);
    });

    // Activate Rich Toolbars for the editor
    $(parentElement).find('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
    });

    // Activate local auto save
    $(parentElement).find('[data-behavior~=local-auto-save]').each(function() {
      new LocalAutoSave(this);
    });

    parentElement.querySelectorAll('[data-behavior~=fetch]').forEach(function(item) {
      fetch(item.dataset.path, { credentials: 'include' })
        .then(function(response) { return response.text(); })
        .then(function(html) {
          item.innerHTML = html;
          $(item).trigger('dradis:fetch');
          initBehaviors(item);
        });
    });

    // Allow page anchors to work
    $(parentElement).find('[data-behavior~=deeplinks] >* a').click(function (e) {
      history.pushState(null, null, $(e.target).attr('href'));
    });

    // Show the pane for a given anchor
    $(parentElement).find('[data-behavior~=deeplinks] >* a').each(function() {
      if (window.location.hash == $(this).attr('href')) {
        $(this).tab('show');
      }
    });
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors(document.querySelector('body'));
  });
})($, window);
