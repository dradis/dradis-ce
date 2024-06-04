document.addEventListener('turbolinks:load', function () {
  $('[data-behavior~=liquid-async]').each(function () {
    const that = this,
      data = { text: $(that).attr('data-content') },
      $spinner = $(that).prev().find('[data-behavior~=liquid-spinner');

    fetch($(that).attr('data-path'), {
      method: 'POST',
      headers: {
        Accept: 'text/html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
      },
      body: JSON.stringify(data),
    })
      .then((response) => response.text())
      .then(function (html) {
        $(that).html(html);
        $spinner.addClass('d-none');
      });
  });
});
