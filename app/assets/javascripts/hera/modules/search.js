document.addEventListener('turbolinks:load', function () {
  $('[data-behavior~=form-search]').hover(function () {
    $(this).find('[data-behavior~=search-query]').focus();
  });

  $('[data-behavior~=search-button]').on('click', function (e) {
    e.preventDefault();
    submitSearch($(this).parents('form'));
  });

  $('[data-behavior~=search-query]').on('keypress', function (e) {
    if (e.which === 13) {
      submitSearch($(this).parents('form'));
    }
  });

  if ($('body.search.index').length) {
    const highlighter = new SearchWordHighlight();
    const query = $('.form-search #q').val();
    $('#tbl-search .search-matches').each(function () {
      highlighter.highlight($(this), query);
    });
  }
});

function submitSearch($form) {
  if ($form.find('[data-behavior~=search-query]').val() !== '') {
    $form.submit();
    setTimeout(() => {
      $form.find('[data-behavior~=search-query]').val('Searching...');
    }, 100);
  } else {
    $form
      .find('[data-behavior~=search-query]')
      .effect('shake', { direction: 'left', times: 2, distance: 5 }, 'fast')
      .focus();
  }
}

class SearchWordHighlight {
  highlight(element, term) {
    let src_str = element.html();
    term = term.replace(/(\s+)/, '(<[^>]+>)*$1(<[^>]+>)*');
    const pattern = new RegExp('(' + term + ')', 'gi');
    src_str = src_str.replace(pattern, '<mark>$1</mark>');
    src_str = src_str.replace(
      /(<mark>[^<>]*)((<[^>]+>)+)([^<>]*<\/mark>)/,
      '$1</mark>$2<mark>$4'
    );
    element.html(src_str);
  }
}
