document.addEventListener("turbolinks:load", function() {
  var $modal = $('[data-behavior~=image-modal]');

  $('[data-behavior~=content-textile] img').each(function() {
    $(this).attr('data-toggle', 'modal').attr('data-target', '[data-behavior~=image-modal]');
  });

  $('[data-behavior~=content-textile] img').click(function() {
    var title = $(this).attr('alt');

    $modal.find('[data-behavior~=modal-title]').text(title);
    $modal.find('[data-behavior~=image-modal-image]').attr('src', $(this).attr('src'));
  });
});
