document.addEventListener('turbolinks:load', function () {
  if ($('[data-behavior~=state-radio]').length) {
    function updateBtnText($selectedRadio) {
      var selectedState = $selectedRadio
        .parent()
        .find('[data-behavior~=state-label]');

      $selectedRadio
        .closest('[data-behavior~=btn-states]')
        .find('[data-behavior~=state-button]')
        .text(selectedState.text());
    }

    $('[data-behavior~=state-radio]').on('change', function () {
      var $selectedRadio = $(this);
      updateBtnText($selectedRadio);
    });
  }
});
