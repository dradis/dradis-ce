# highlight search term inside search list
jQuery ->
  if ($('body.search.index').length)
    src_str = $('#tbl-search .search-match').html()
    term = $(".navbar-search #q").val()
    term = term.replace(/(\s+)/, '(<[^>]+>)*$1(<[^>]+>)*')
    pattern = new RegExp('(' + term + ')', 'gi')
    src_str = src_str.replace(pattern, '<mark>$1</mark>')
    src_str = src_str.replace(/(<mark>[^<>]*)((<[^>]+>)+)([^<>]*<\/mark>)/, '$1</mark>$2<mark>$4')
    $('#tbl-search .search-match').html src_str
