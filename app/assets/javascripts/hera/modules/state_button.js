// Called from initBehaviors() since Turbo Frame swaps don't fire turbo:load.
const updateBtn = ($selectedRadio) => {
  const selectedState = $selectedRadio
    .parent()
    .find('[data-behavior~=state-label]');

  const $stateBtn = $selectedRadio
    .closest('[data-behavior~=btn-states]')
    .find('[data-behavior~=state-button]');

  $stateBtn.text(selectedState.text());
  $stateBtn.parent().attr('data-state', $selectedRadio.val());
};

window.initStateButton = (parentElement) => {
  const $stateRadios = $(parentElement).find(
    '[data-behavior~=state-radio]'
  );

  if (!$stateRadios.length) return;

  $stateRadios.off('change.stateButton').on('change.stateButton', (event) => {
    updateBtn($(event.currentTarget));
  });
};
