# don't put my js functions on global scope
# assign them to Dradis scope, this could be moved in main js file
window.Dradis or (window.Dradis = {})

# highlight search term inside search list
class Dradis.WordHighlight
  highlight: (element, word) ->
    src_str = element.html()
    word = word.replace(/(\s+)/, '(<[^>]+>)*$1(<[^>]+>)*')
    pattern = new RegExp('(' + word + ')', 'gi')
    src_str = src_str.replace(pattern, '<mark>$1</mark>')
    src_str = src_str.replace(/(<mark>[^<>]*)((<[^>]+>)+)([^<>]*<\/mark>)/, '$1</mark>$2<mark>$4')
    element.html src_str


jQuery ->
  return unless $('body.search.index').length > 0
  highlighter = new Dradis.WordHighlight
  word = $(".navbar-search #q").val()
  $('#tbl-search .search-matches').each ->
    highlighter.highlight($(this), word)
