document.addEventListener('turbolinks:load', function() {
  if ($('body.unauthenticated').length) {
    var charCount = 0,
        strings = [
          'The same reports, in a fraction of the time',
          'Deliver consistent results, every time',
          'Combine output from multiple tools easily',
          'Spend less time reporting and more time testing',
          'The entire team knows how the project is going',
          'Working better, together'
        ],
        randomStringIndex = Math.floor(Math.random() * strings.length),
        randomString = strings[randomStringIndex];

    setTimeout(function() {
      setInterval(function() {
        if (charCount <= randomString.length) {
          $('[data-behavior~=mission-text]').text(randomString.substring(0, charCount));
          charCount += 1;
        }
      }, 20);
    }, 500);

    $('[data-behavior~=logo-icons]').addClass('expand');

    $('[data-behavior~=animate-click]').on('click', function() {
      $('[data-behavior~=logo-icons]').removeClass('expand').addClass('shrink');
      setTimeout(function() {
        $('[data-behavior~=logo-icons]').removeClass('shrink').addClass('expand');
      }, 250)
    });
  }
});
