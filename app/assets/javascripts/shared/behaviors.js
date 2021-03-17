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

    $parent.find('[data-behavior~=fetch]').each(async function() {
      var element = this;
      element.innerHTML = '<div class="loader"><div class="spinner-border text-primary" role="status"><span class="sr-only">Loading...</span></div></div>';

      var promiseResult = await fetch(element.dataset.path);
      var html = await promiseResult.text();

      element.innerHTML = html;

      initBehaviors($(element));
    })
  }

  if (typeof Turbolinks !== 'undefined' && Turbolinks !== null) {
    document.addEventListener('turbolinks:load', function() {
      initBehaviors($('body'));
    })
  } else {
    $(document).ready(function(){
      initBehaviors($('body'));
    })
  }
})($, window);
