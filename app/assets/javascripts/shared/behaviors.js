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

      // Activate QuoteSelector after Rich toolbars
      // This can be globally scoped because the QuoteSelector does not allow
      // double binding
      $('[data-behavior~=content-textile]').each(function() {
        new QuoteSelector(this);
      });
    });

    // Activate local auto save
    $(parentElement).find('[data-behavior~=local-auto-save]').each(function() {
      new LocalAutoSave(this);
    });

    $(parentElement).find('[data-behavior~=fetch]').each(function() {
      var that = this;
      $.ajax(that.dataset.path, { credentials: 'include' })
        .then(function(response) { return response; })
        .then(function(html) {
          $(that).html(html);
          $(that).trigger('dradis:fetch');
          initBehaviors(that);
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
