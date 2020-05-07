document.addEventListener('turbolinks:load', function(){
  function setBtnText(prefix, state) {
    var $submitBtn = $('[data-behavior~=state-submit-button]', $(this));
    var verboseState = (state == 'review') ? 'ready for review' : state;

    $('[data-state]', $(this)).each(function() {
      $(this).removeClass('selected');
    });
    $('[data-state~=' + state + ']', $(this)).addClass('selected');
    
    $submitBtn.prop('value', prefix + ' ' + verboseState + ' Issue');
  }

  $('[data-behavior~=state-menu]').each( function() {
    var $scope = $(this);
    var currentState = $('[data-behavior~=issue-state]', $scope).val();
    var textPrefix = $('body.new').length ? 'create' : 'update';

    setBtnText.call(this, textPrefix, currentState);

    $('[data-state-header]', $scope).each(function() {
      var headerText = $(this).text();
      $(this).text(textPrefix + headerText);
    });

    $('[data-state]', $scope).click(function () {
      var selectedState = $(this).data('state');
      var $stateField = $('[data-behavior~=issue-state]', $scope);

      setBtnText.call($scope[0], textPrefix, selectedState);
      $stateField.val(selectedState);
    });
  });
});
