document.addEventListener('turbolinks:load', function(){
  function setBtnText(state) {
    var $submitBtn = $('[data-behavior~=state-submit-button]', $(this));

    $('[data-state]').removeClass('selected')

    var $selectedDropdownItem = $('[data-state~=' + state + ']', $(this))
    $selectedDropdownItem.addClass('selected');

    $submitBtn.prop('value', $selectedDropdownItem.find('[data-state-header]').text());
  }

  $('[data-behavior~=state-menu]').each( function() {
    var $scope = $(this);

    $('[data-state]', $scope).click(function () {
      var selectedState = $(this).data('state');
      var $stateField = $('[data-behavior~=issue-state]', $scope);

      setBtnText.call($scope[0], selectedState);
      $stateField.val(selectedState);
    });
  });
});
