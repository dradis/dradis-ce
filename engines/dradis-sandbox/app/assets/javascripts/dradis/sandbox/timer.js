document.addEventListener('turbo:load', function () {
  const badge = document.querySelector('[data-sandbox-reset-minutes]');
  if (!badge) return;

  const resetMinutes = parseInt(badge.dataset.sandboxResetMinutes);
  const timerElement = document.querySelector('[data-behavior="timer"]');
  const bufferSeconds = 10;
  let isRestarting = false;

  function updateTimer() {
    const now = new Date();
    const secondsIntoCycle =
      (now.getMinutes() % resetMinutes) * 60 + now.getSeconds();
    const totalSeconds = Math.max(
      0,
      resetMinutes * 60 - secondsIntoCycle - bufferSeconds,
    );
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;

    timerElement.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

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
      setTimeout(() => window.location.reload(), bufferSeconds * 1000);
      return;
    }
  }

  updateTimer();
  setInterval(updateTimer, 1000);
});
