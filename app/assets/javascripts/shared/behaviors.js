document.addEventListener('turbolinks:load', function(){
  //Activate jQuery.Textile
  $('.textile').textile();

  // Activate Rich Toolbars for the editor
  $('[data-behavior~=rich-toolbar]').each(function() {
    new EditorToolbar($(this));
  });

  $('[data-behavior~=local-auto-save]').each(function() {
    new LocalAutoSave(this);
  });
})
