(function($, window){
  function initBehaviors($parent) {

    //Activate jQuery.Textile
    $parent.find('.textile').textile();

    // Activate Rich Toolbars for the editor
    $parent.find('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
    });

    // Activate Local Auto Save for editor and comments
    $parent.find('[data-behavior~=local-auto-save]').each(function() {
      new LocalAutoSave(this);
    });

    new Comments;
    new Subscriptions;

    $parent.find('[data-behavior~=fetch]').each(function() {
      var item = this;

      fetch(item.dataset.path, { credentials: 'include' })
        .then(function(response){ return response.text(); })
        .then(function(html) {
          item.innerHTML = html;
          initBehaviors($(item));
        });
    });
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors($('body'));
  })
})($, window);
