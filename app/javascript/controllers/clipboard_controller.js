import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { text: String };

  connect() {
    this.clipboard = new Clipboard(this.element, { text: () => this.textValue });
    this.clipboard.on('success', (e) => {
      e.clearSelection();
      this.showFeedback('Copied to clipboard!');
    });
    this.clipboard.on('error', (e) => {
      const actionKey = e.action === 'cut' ? 'X' : 'C';
      const modifierKey = /Mac/i.test(navigator.userAgent) ? '⌘' : 'Ctrl';
      this.showFeedback(`Press ${modifierKey}-${actionKey} to ${e.action}`);
    });
  }

  disconnect() {
    this.clipboard.destroy();
    this.disposeFeedback();
  }

  disposeFeedback() {
    clearTimeout(this.feedbackTimeout);
    this.feedback?.dispose();
    this.feedback = null;
  }

  showFeedback(title) {
    this.disposeFeedback();
    this.feedback = new bootstrap.Tooltip(this.element, {
      placement: 'bottom',
      title: title,
      trigger: 'manual',
    });
    this.feedback.show();
    this.feedbackTimeout = setTimeout(() => this.feedback.hide(), 1000);
  }
}
