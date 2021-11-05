(function($, window){
  function initBehaviors(parentElement) {
    //Activate jQuery.Textile
    $('.textile').textile();

    // Activate DataTables
    $('[data-behavior~=dradis-datatable]').each(function() {
      new DradisDatatable(this);
    });

    // Activate Rich Toolbars for the editor
    $('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
    });

    // Activate QuoteSelector after Rich toolbars
    $('[data-behavior~=content-textile]').each(function() {
      new QuoteSelector(this);
    });

    // Activate local auto save
    $('[data-behavior~=local-auto-save]').each(function() {
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
    $('[data-behavior~=deeplinks] >* a').click(function (e) {
      history.pushState(null, null, $(e.target).attr('href'));
    });

    // Show the pane for a given anchor
    $('[data-behavior~=deeplinks] >* a').each(function() {
      if (window.location.hash == $(this).attr('href')) {
        $(this).tab('show');
      }
    });
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors(document.querySelector('body'));
  });
})($, window);
