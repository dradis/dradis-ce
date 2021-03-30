(function($, window){
  function initBehaviors(parentElement) {
    //Activate jQuery.Textile
    $('.textile').textile();

    // Activate Rich Toolbars for the editor
    $('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
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
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors(document.querySelector('body'));
  });
})($, window);
