document.addEventListener('turbolinks:load', function(){
  // Activate jQuery.Textile
  $('.textile').textile();
  
  // Activate Rich Toolbars for the editor
  $('[data-behavior~=rich-toolbar]').each(function() {
    new EditorToolbar($(this));
  });

  // Activate Bootstrap tooltips for icons
  $('i[data-toggle="tooltip"]').tooltip()
})
