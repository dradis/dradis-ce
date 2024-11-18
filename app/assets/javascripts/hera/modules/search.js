document.addEventListener('turbolinks:load', function () {
  $('[data-behavior~=form-search]').hover(function () {
    $('[data-behavior~=search-query]').focus();
  });

  var submitSearch = function () {
    if ($('[data-behavior~=search-query]').val() !== '') {
      $('[data-behavior~=form-search]').submit();
      $('[data-behavior~=search-query]').val('Searching...');
      return false;
    } else {
      $('[data-behavior~=search-query]')
        .effect('shake', { direction: 'left', times: 2, distance: 5 }, 'fast')
        .focus();
    }
  };

  $('[data-behavior~=search-button]').on('click', function (e) {
    e.preventDefault();
    submitSearch();
  });

  $('[data-behavior~=search-query]').on('keypress', function (e) {
    if (e.which === 13) {
      submitSearch();
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
