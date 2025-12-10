function liquidAsync() {
  $('[data-behavior~=liquid-async]').each(function () {
    const that = this,
      data = { text: $(that).attr('data-content') },
      $spinner = $(that).prev().find('[data-behavior~=liquid-spinner');

    const requiresSortUpdate = $(that).is('[data-sort]')

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

        if (requiresSortUpdate) {
            const liquidText = $('<div>').html(html).text().trim(); 
            $(that).attr('data-sort', liquidText); 
        }

        $(that).trigger('dradis:liquid-rendered');
        $spinner.addClass('d-none');
      });
  });
};

document.addEventListener('turbo:load', liquidAsync);
$(document).on('dradis:fetch', function(event) {
    liquidAsync();
});
