document.addEventListener( "turbolinks:load", function(){
  if ($('[data-behavior~=state-menu]').length) {
    var btnText = '',
        $submitBtn = $('[data-behavior~=state-submit-button]');

    if ($('body.new').length) {
      btnText = 'Create Draft Issue';
      $('[data-state~=draft]').addClass('selected');
    }
    else {
      // This will need to be updated to use the current state of the issue on load.
      btnText = 'Update Draft Issue';
    }

    $submitBtn.prop('value', btnText);

    $('[data-state]').click(function () {
      var selectedState = $(this).data('state');

      $('[data-state]').each(function() {
        $(this).removeClass('selected');
      });
      
      $(this).addClass('selected');
          
      switch (selectedState) {
        case 'draft':
          btnText = 'Create Draft Issue';
          break;
        case 'review':
          btnText = 'Create Ready for Review Issue';
          break;
        case 'published':
          btnText = 'Create Published Issue';
          break;
      }

      $submitBtn.prop('value', btnText);
    });
  }
});
