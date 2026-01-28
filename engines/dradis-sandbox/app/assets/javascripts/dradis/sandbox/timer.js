(function () {
  var intervalId = null;

  document.addEventListener('turbo:load', function () {
    // Clear any previous interval to avoid stacking across Turbo navigations
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }

    // Remove any existing timer (defensive, in case it survived navigation)
    var existing = document.querySelector('.sandbox-timer');
    if (existing) existing.remove();

    // Read config from <meta> tag if present, otherwise default to 20 minutes.
    // To override, add to the <head>:
    //   <meta name="sandbox-reset-minutes" content="30">
    var metaTag = document.querySelector('meta[name="sandbox-reset-minutes"]');
    var resetMinutes = metaTag ? parseInt(metaTag.content, 10) : 20;
    var bufferSeconds = 10;
    var isRestarting = false;

    // Build the timer element and inject it into the DOM
    var badge = document.createElement('span');
    badge.className = 'sandbox-timer badge text-bg-primary';

    var timerSpan = document.createElement('span');
    timerSpan.className = 'font-monospace fw-light';
    timerSpan.textContent = '00:00';

    badge.appendChild(document.createTextNode('Restarts in: '));
    badge.appendChild(timerSpan);
    document.body.appendChild(badge);

    function updateTimer() {
      var now = new Date();
      var secondsIntoCycle =
        (now.getMinutes() % resetMinutes) * 60 + now.getSeconds();
      var totalSeconds = Math.max(
        0,
        resetMinutes * 60 - secondsIntoCycle - bufferSeconds,
      );
      var minutes = Math.floor(totalSeconds / 60);
      var seconds = totalSeconds % 60;

      timerSpan.textContent =
        String(minutes).padStart(2, '0') +
        ':' +
        String(seconds).padStart(2, '0');

      badge.classList.remove(
        'text-bg-primary',
        'text-bg-warning',
        'text-bg-danger',
      );

      if (totalSeconds < 60) {
        badge.classList.add('text-bg-danger');
      } else if (totalSeconds < 300) {
        badge.classList.add('text-bg-warning');
      } else {
        badge.classList.add('text-bg-primary');
      }

      if (totalSeconds === 0 && !isRestarting) {
        isRestarting = true;
        badge.innerHTML =
          'Restarting... <span class="spinner-border spinner-border-sm" role="status"></span>';
        setTimeout(function () {
          window.location.reload();
        }, bufferSeconds * 1000);
        return;
      }
    }

    updateTimer();
    intervalId = setInterval(updateTimer, 1000);
  });
})();
