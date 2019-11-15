document.addEventListener('turbolinks:load', function(){
  if ($('body.styles_tylium')) {
    $('[data-behavior~=reveal-code]').on('click', function() {
      $(this).closest('[data-behavior~=content-container').find('[data-behavior~=style-code]').toggleClass('d-none');
    })
  }
});
