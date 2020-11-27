document.addEventListener('turbolinks:load', function(){
  //Activate jQuery.Textile
  $('.textile').textile();
  
  // Activate Rich Toolbars for the editor
  $('[data-behavior~=rich-toolbar]').each(function() {
    new EditorToolbar($(this));
  });

  // Activate Modals for images within textile rendered areas
  const $modal = $('[data-behavior~=image-modal]');
  const targetImgs = 'img[data-toggle=modal]';

  var modal = new ImageModal([], 0 , $modal);

  $('[data-behavior~=view-content]').on('click', targetImgs, function() {
    modal.unbind();
    modal = new ImageModal([], 0, $modal)

    scope = ($(this).parents('[data-behavior~=comment-feed]').length ? 'comment-feed' : 'content-textile');
    $(this).parents('[data-behavior~='+scope+']').find(targetImgs).each(function() {
      modal.addImage(this);
    });

    var index = modal.getIndex(this);
    modal.loadImage(index);
  });
})
