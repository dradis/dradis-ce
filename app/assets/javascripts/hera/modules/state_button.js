// Called from initBehaviors() since Turbo Frame swaps don't fire turbo:load.
(function ($, window) {
  function updateBtn($selectedRadio) {
    var selectedState = $selectedRadio
      .parent()
      .find('[data-behavior~=state-label]');

    var $stateBtn = $selectedRadio
      .closest('[data-behavior~=btn-states]')
      .find('[data-behavior~=state-button]');

    $stateBtn.text(selectedState.text());
    $stateBtn.parent().attr('data-state', $selectedRadio.val());
  }

  function initStateButton(parentElement) {
    $(parentElement)
      .find('[data-behavior~=state-radio]')
      .off('change.stateButton')
      .on('change.stateButton', function () {
        updateBtn($(this));
      });
  }

  window.initStateButton = initStateButton;
})(jQuery, window);
