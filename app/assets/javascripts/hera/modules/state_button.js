// Called from initBehaviors() since Turbo Frame swaps don't fire turbo:load.
(function (window) {
  function updateBtn($selectedRadio) {
    if ($selectedRadio.prop('disabled')) return;

    const selectedState = $selectedRadio
      .parent()
      .find('[data-behavior~=state-label]');

    const $stateGroup = $selectedRadio.closest('[data-behavior~=btn-states]');
    const $stateBtn = $stateGroup.find('[data-behavior~=state-button]');
    const $explicitTarget = $stateGroup.find('[data-behavior~=state-target]');
    const $stateTarget = $explicitTarget.length ? $explicitTarget : $stateBtn.parent();
    const state = $selectedRadio.val();

    $stateBtn.text(selectedState.text());
    $stateTarget.attr('data-state', state).data('state', state);

    $stateGroup.find('[data-behavior~=state-toggle]').each((_, toggle) => {
      bootstrap.Dropdown.getInstance(toggle)?.hide();
    });
  }

  window.initStateButton = (parentElement) => {
    const $stateRadios = $(parentElement).find(
      '[data-behavior~=state-radio]'
    );

    if (!$stateRadios.length) return;

    $stateRadios
      .off('change.stateButton')
      .on('change.stateButton', (event) => {
        updateBtn($(event.currentTarget));
      });
  };
})(window);
