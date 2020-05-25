document.addEventListener('turbolinks:load', function(){
  // Activate Rich Toolbars for the editor
  $('[data-behavior~=rich-toolbar]').each(function() {
    new EditorToolbar($(this));
  });
})
