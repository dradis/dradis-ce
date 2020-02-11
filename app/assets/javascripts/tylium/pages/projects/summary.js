document.addEventListener('turbolinks:load', function(){
  if ($('body.projects.show').length) {
    $('a[data-toggle="collapse"]').click(function () {
      if ($(this).hasClass('collapsed')) {
        $(this).find('[data-behavior~=caret-icon]').removeClass('fa-caret-down').addClass('fa-caret-up');
      }
      else {
        $(this).find('[data-behavior~=caret-icon]').removeClass('fa-caret-up').addClass('fa-caret-down');
      }
    });
  }
});
