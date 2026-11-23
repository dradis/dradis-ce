import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    const clipboard = new Clipboard(this.element);

    clipboard.on('success', function (e) {
      const $copyBtn = $(e.trigger);
      e.clearSelection();
      $copyBtn.tooltip({
        placement: 'bottom',
        title: 'Copied to clipboard!',
        trigger: 'manual',
      });
      $copyBtn.tooltip('show');
      setTimeout(function () {
        $copyBtn.tooltip('hide');
      }, 1000);
    });

    clipboard.on('error', function (e) {
      const actionKey = e.action === 'cut' ? 'X' : 'C',
        $copyBtn = $(e.trigger);
      let actionMsg;

      if (/Mac/i.test(navigator.userAgent)) {
        actionMsg = 'Press ⌘-' + actionKey + ' to ' + e.action;
      } else {
        actionMsg = 'Press Ctrl-' + actionKey + ' to ' + e.action;
      }

      $copyBtn.tooltip({
        placement: 'bottom',
        title: actionMsg,
        trigger: 'manual',
      });
      $copyBtn.tooltip('show');
      setTimeout(function () {
        $copyBtn.tooltip('hide');
      }, 1000);
    });
  }
}
