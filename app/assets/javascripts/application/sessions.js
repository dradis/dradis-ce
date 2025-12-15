document.addEventListener('turbo:load', function () {
  if ($('body.unauthenticated').length) {
    var charCount = 0,
      strings = setStrings(),
      randomStringIndex = Math.floor(Math.random() * strings.length),
      randomString = strings[randomStringIndex];

    function setStrings() {
      if ($('body.unauthenticated').hasClass('december')) {
        return [
          'Yippie Ki Yay!',
          'Follow the white rabbit',
          'Take the red pill',
          'There is no spoon',
          'Eat, sleep, hack, repeat',
          "I am Jack's complete lack of surprise",
          'Greetings Professor Falken',
          "There is no right and wrong. There's only fun and boring.",
          'The cake is a lie',
        ];
      } else if ($('body.unauthenticated').hasClass('may-4th')) {
        return [
          'May the Fourth be with you.',
          'This is the way.',
          "Help me, Obi-Wan Kenobi. You're my only hope.",
          'In my experience there is no such thing as luck.',
          'A long time ago in a galaxy far, far away...',
          'I find your lack of faith disturbing.',
          'Your focus determines your reality.',
          'Do. Or do not. There is no try.',
          "I've got a bad feeling about this.",
          'The Force will be with you. Always.',
          'You were the chosen one!',
          'I am your father,',
          'Let the Wookie win.',
          'Be careful not to choke on your aspirations.',
          "Let's keep a little optimism here.",
          "I'm not leaving my fate up to chance.",
          "Don't just blindly follow the program, exercise some free will.",
          "In my experience, there's no such thing as luck.",
          'Persistence without insight will lead to the same outcome.',
          "As long as there's light, we've got a chance.",
          'The greatest teacher, failure is.',
        ];
      } else {
        return [
          'The same reports, in a fraction of the time',
          'Deliver consistent results, every time',
          'Combine output from multiple tools easily',
          'Spend less time reporting and more time testing',
          'The entire team knows how the project is going',
          'Working better, together',
        ];
      }
    }

    setTimeout(function () {
      setInterval(function () {
        if (charCount <= randomString.length) {
          $('[data-behavior~=mission-text]').text(
            randomString.substring(0, charCount),
          );
          charCount += 1;
        }
      }, 20);
    }, 500);

    $('[data-behavior~=logo-icons]').addClass('expand');

    $('[data-behavior~=animate-click]').on('click', function () {
      $('[data-behavior~=logo-icons]').removeClass('expand').addClass('shrink');
      setTimeout(function () {
        $('[data-behavior~=logo-icons]')
          .removeClass('shrink')
          .addClass('expand');
      }, 250);
    });
  }
});
