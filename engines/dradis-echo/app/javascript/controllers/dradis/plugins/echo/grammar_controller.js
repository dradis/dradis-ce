import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['checkButton', 'status']
  static values  = {
    commentableType:        String,
    commentableId:          String,
    grammarCheckUrl:        String,
    grammarReplacementsUrl: String
  }

  connect() {
    this.highlighter = null;
    this._onLiquidRendered = () => this.check();
    document.addEventListener('dradis:liquid-rendered', this._onLiquidRendered);
  }

  disconnect() {
    document.removeEventListener('dradis:liquid-rendered', this._onLiquidRendered);
  }

  check() {
    const contentEl = document.querySelector('[data-behavior~=content-textile]');
    if (!contentEl) return;

    this.setStatus('Checking...');
    this.checkButtonTarget.disabled = true;

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const body = new URLSearchParams({
      commentable_type: this.commentableTypeValue,
      commentable_id:   this.commentableIdValue
    });

    fetch(this.grammarCheckUrlValue, {
      method:  'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': csrfToken,
        'Accept':       'application/json'
      },
      body: body.toString()
    })
    .then(r => {
      if (!r.ok) return r.json().then(data => { throw new Error(data.error); });
      return r.json();
    })
    .then(matches => {
      this.highlighter = new GrammarHighlighter(contentEl, {
        commentableType:        this.commentableTypeValue,
        commentableId:          this.commentableIdValue,
        grammarReplacementsPath: this.grammarReplacementsUrlValue
      });
      this.highlighter.highlight(matches);

      const count = matches.length;
      this.setStatus(count === 0 ? 'No issues found.' : `${count} issue${count === 1 ? '' : 's'} found.`);
      this.checkButtonTarget.disabled = false;
    })
    .catch(err => {
      console.error('Grammar check failed:', err);
      this.setStatus('Check failed. Is LanguageTool running?');
      this.checkButtonTarget.disabled = false;
    });
  }

  clear() {
    if (this.highlighter) {
      this.highlighter.clearHighlights();
      this.highlighter = null;
    }
    this.setStatus('');
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }
}
