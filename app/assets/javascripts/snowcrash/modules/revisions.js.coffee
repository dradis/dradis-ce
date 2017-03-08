$ ->
  if $('.diff-body').length
    delRegex = /\[31m([\s\S]*?)\[0m/g
    insRegex = /\[32m([\s\S]*?)\[0m/g

    diffText = $('.diff-body').html()

    newText =
      diffText.
      replace(delRegex, '<del class="differ">$1</del>').
      replace(insRegex, '<ins class="differ">$1</ins>')

    $('.diff-body').html(newText)
