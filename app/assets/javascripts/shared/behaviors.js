(function($, window){
  function initBehaviors() {

    //Activate jQuery.Textile
    $('.textile').textile();

    // Activate Rich Toolbars for the editor
    $('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
    });

    // Activate Local Auto Save for editor and comments
    $('[data-behavior~=local-auto-save]').each(function() {
      new LocalAutoSave(this);
    });
  }

  function initFetchComments() {
    $('[data-behavior~=fetch-comments]').each(async function() {
      var element = this;
      element.innerHTML = '<div class="loader"><div class="spinner-border text-primary" role="status"><span class="sr-only">Loading comments...</span></div></div>';

      var promiseResult = await fetch(element.dataset.path);
      var html = await promiseResult.text();

      element.innerHTML = html;
      initBehaviors();
      new Comments;
    })
  }

  if (typeof Turbolinks !== 'undefined' && Turbolinks !== null) {
    document.addEventListener('turbolinks:load', function() {
      initBehaviors();
      initFetchComments();
    })
  } else {
    $(document).ready(function(){
      initBehaviors();
      initFetchComments();
    })
  }
})($, window);
