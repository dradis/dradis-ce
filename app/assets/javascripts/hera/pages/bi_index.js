document.addEventListener('turbo:load', function () {
  if ($('body.static_pages.bi_index').length) {
    $(document).on('dradis:fetch turbo:frame-render', function (event) {
      const $widgetFilter = $(
        event.target.closest('[data-behavior~=fetch]')
      ).find('[data-behavior~=widget-filter]');

      if ($widgetFilter.length) {
        if (event.type == 'turbo:frame-render') {
          window.initBehaviors(
            event.target
              .closest('[data-behavior~=fetch]')
              .querySelector('[data-behavior~=widget-content]')
          );
        }

        $widgetFilter.on('change', function (e) {
          const $container = $(e.target).parents('[data-behavior~=fetch]');
          $container.find('[data-behavior~=fetch-loader]').removeClass('d-none');
          $container.find('[data-behavior~=widget-content]').addClass('d-none');
          e.target.closest('form').requestSubmit();
        });
      }
    });
  }
});
