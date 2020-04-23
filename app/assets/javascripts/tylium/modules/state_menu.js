document.addEventListener( "turbolinks:load", function(){

  function setBtnText(prefix, state) {
    var btnText, $submitBtn = $('[data-behavior~=state-submit-button]');
    var verboseState = ((state == 'review') ? 'ready for review' : state);

    $('[data-state]').each(function() {
      $(this).removeClass('selected');
    });
    
    $('[data-state~=' + state + ']').addClass('selected');

    btnText = prefix + ' ' + verboseState + ' Issue';

    $submitBtn.prop('value', btnText);
  }

  if ($('[data-behavior~=state-menu]').length) {
    var textPrefix, currentState;

    // once we have states implemented this if block can be streamlined
    if ($('body.new').length) {
      textPrefix = 'create';
      currentState = 'draft';
      setBtnText(textPrefix, currentState);
    }
    else {
      textPrefix = 'update';
      currentState = 'draft'; // This will need to be updated to use the current state of the issue on load.
      setBtnText(textPrefix, currentState);
    }

    $('[data-state-header]').each(function() {
      var headerText = $(this).text();
      $(this).text(textPrefix + headerText);
    });

    $('[data-state]').click(function () {
      var selectedState = $(this).data('state');
      setBtnText(textPrefix, selectedState);
    });
  }
});
