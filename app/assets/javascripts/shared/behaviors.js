(function($, window){
  function initBehaviors(parentElement) {
    // Activate jQuery.Textile
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

    // Fetch content
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

    // Init Bootstrap tooltips
    $('[data-toggle~=tooltip]').tooltip();
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors(document.querySelector('body'));

    // Because this is an event and not a data-driven behavior, we can leave it
    // out of initBehaviors and attach the listener to document directly.
    //
    // In particular we're after jquery.textile forms that get rendered post page
    // load via ajax.
    $(document).on('textile:formLoaded', '.textile-form', function(event){
      // We trigger a single formLoaded event for the containing form, but we
      // have to attach EditorToolbar to individual textareas within it.
      $(event.target).find('[data-behavior~=rich-toolbar]').each(function() {
        new EditorToolbar($(this));
      });
    });
  });
})($, window);
