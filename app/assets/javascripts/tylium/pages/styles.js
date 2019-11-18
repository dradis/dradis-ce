document.addEventListener('turbolinks:load', function(){
  if ($('body.styles_tylium')) {

    $('[data-behavior~=quick-nav-btn]').on('click', function() {
      let target = $(this).data('target');
      $('[data-id~=' + target + ']')[0].scrollIntoView({behavior: "smooth"});
    })
  }
});
