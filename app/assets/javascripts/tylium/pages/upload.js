document.addEventListener('turbolinks:load', function () {
  if ($('body.upload.index').length) {
    $('[data-behavior~=tool-select]').on('change', function () {
      let toolsWithInheritedState = [
        'Dradis::Plugins::Projects::Upload::Package',
        'Dradis::Plugins::Projects::Upload::Template',
      ];

      if (toolsWithInheritedState.includes($(this).val())) {
        $('[data-behavior~=state-select]')
          .attr('disabled', true)
          .addClass('disabled')
          .find('option:selected')
          .text('Imported from file');
      } else {
        let $option = $('[data-behavior~=state-select]').find(
          'option:selected'
        );

        $('[data-behavior~=state-select]')
          .attr('disabled', false)
          .css('textTransform', 'capitalize')
          .removeClass('disabled');

        $option.text($option.val().replaceAll('_', ' '));
      }
    });
  }
});
