document.addEventListener('turbolinks:load', function() {
  if ($('body.unauthenticated').length) {
    var charCount = 0,
        strings = [
          'Combine the output form your favorite security tools',
          'Spend less time reporting and more time testing',
          'Working better, together',
          'Share a common view of the entire project',
          'The same reports, in a fraction of the time',
          'Deliver consistent results, every time'
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
