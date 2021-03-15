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
    $('[data-behavior~=fetch-comments]').each(function() {
      var element = this
      $.ajax({
        method: 'GET',
        url: element.dataset.path,

        success: function(data) {
          element.innerHTML = data;
          initBehaviors();
          new Comments
        }
      });
    })
  }

  if (typeof Turbolinks !== "undefined" && Turbolinks !== null) {
    document.addEventListener('turbolinks:load', function() {
      initBehaviors()
      initFetchComments();
    })
  } else {
    $(document).ready(function(){
      initBehaviors();
      initFetchComments();
    })
  }
})($, window);
