document.addEventListener('turbolinks:load', function() {
  if ($('body.unauthenticated').length) {
    var charCount = 0,
        strings = [
          'Tame the output from multiple scan tools, email threads, and notes',
          'Deliver quality security assessments at light speed',
          'Focus less on tedious reporting tasks and more on testing',
          'Ditch the overhead that drags down project delivery'
        ],
        randomStringIndex = Math.floor(Math.random() * strings.length),
        randomString = strings[randomStringIndex];

    setTimeout(function() {
      window.setInterval(function() {
        if (charCount <= randomString.length) {
          $('[data-behavior~=mission-text]').text(randomString.substring(0, charCount));
          charCount += 1;
        }
      }, 60);
    }, 500);

    $('[data-behavior~=logo-icons]').addClass('expand');

    $('[data-behavior~=animate-click]').on('click', function() {
      $('[data-behavior~=logo-icons]').removeClass('expand').addClass('shrink');
    });
  }
});
