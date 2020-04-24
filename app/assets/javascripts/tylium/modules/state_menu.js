document.addEventListener('turbolinks:load', function(){
  function setBtnText(prefix, state) {
    var btnText;
    var $submitBtn = $('[data-behavior~=state-submit-button]');
    var verboseState = (state == 'review') ? 'ready for review' : state;

    $('[data-state]').each(function() {
      $(this).removeClass('selected');
    });
    
    $('[data-state~=' + state + ']').addClass('selected');

    btnText = prefix + ' ' + verboseState + ' Issue';

    $submitBtn.prop('value', btnText);
  }

  if ($('[data-behavior~=state-menu]').length) {
    var currentState = $('[data-behavior~=issue-state]').val();
    var textPrefix = $('body.new').length ? 'create' : 'update';

    setBtnText(textPrefix, currentState);

    $('[data-state-header]').each(function() {
      var headerText = $(this).text();
      $(this).text(textPrefix + headerText);
    });

    $('[data-state]').click(function () {
      var selectedState = $(this).data('state');
      var $stateField = $('[data-behavior~=issue-state]');

      setBtnText(textPrefix, selectedState);
      $stateField.val(selectedState);
    });
  }
});
