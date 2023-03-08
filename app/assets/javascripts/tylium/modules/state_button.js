document.addEventListener('turbolinks:load', function () {
  if ($('[data-behavior~=state-radio]').length) {
    function updateBtnText($selectedRadio) {
      selectedState = $selectedRadio
        .parent()
        .find('[data-behavior~=state-label]');
      $('[data-behavior~=state-button]').text(selectedState.text());
    }

    updateBtnText($('[data-behavior~=state-radio]:checked'));

    $('[data-behavior~=state-radio]').on('change', function () {
      updateBtnText($(this));
    });
  }
});
