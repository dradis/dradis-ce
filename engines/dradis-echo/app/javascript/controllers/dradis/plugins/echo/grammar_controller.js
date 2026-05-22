import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['panel', 'panelBody']
  static values  = {
    commentableType:        String,
    commentableId:          String,
    grammarCheckUrl:        String,
    grammarReplacementsUrl: String
  }

  connect() {
    this.highlighter = null;

    const contentEl = this._contentEl();
    if (!contentEl) return;

    this._onLiquidRendered = () => this._fetchAndHighlight();
    contentEl.addEventListener('dradis:liquid-rendered', this._onLiquidRendered);
  }

  disconnect() {
    this._contentEl()?.removeEventListener('dradis:liquid-rendered', this._onLiquidRendered);
  }

  // ----------------------------------------------------------------- private

  _fetchAndHighlight() {
    const contentEl = this._contentEl();
    if (!contentEl) return;

    const storageKey = `grammar_dismissed:${this.commentableTypeValue}:${this.commentableIdValue}`;
    this.highlighter ||= new GrammarHighlighter(contentEl, this, storageKey);

    const body = new URLSearchParams({
      commentable_type: this.commentableTypeValue,
      commentable_id:   this.commentableIdValue
    });

    fetch(this.grammarCheckUrlValue, {
      method:  'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': this._csrf(),
        'Accept':       'application/json'
      },
      body: body.toString()
    })
      .then(r => {
        if (!r.ok) throw new Error(`Grammar check failed: ${r.status}`);
        return r.json();
      })
      .then(matches => this.highlighter.highlight(matches))
      .catch(err => console.warn('GrammarCheck: check failed:', err));
  }

  showSuggestion(match) {
    const body = this.panelBodyTarget;
    body.replaceChildren();

    const quote = document.createElement('blockquote');
    quote.className   = 'fs-6 border-start border-3 ps-3 text-body-secondary mb-3';
    quote.textContent = match.exact;
    body.appendChild(quote);

    const comment = document.createElement('div');
    comment.className = 'inline-thread-comment py-2';
    comment.innerHTML =
      '<div class="d-flex">' +
        '<div class="me-2 flex-shrink-0">' +
          '<i class="fa-solid fa-spell-check text-muted mt-1"></i>' +
        '</div>' +
        '<div class="w-100">' +
          '<div class="mb-1"><span class="fw-semibold small">LanguageTool</span></div>' +
          '<div class="content"></div>' +
        '</div>' +
      '</div>';

    const content = comment.querySelector('.content');

    const message = document.createElement('p');
    message.className   = 'mb-2';
    message.textContent = match.message;
    content.appendChild(message);

    if (match.replacements?.length) {
      const replacements = document.createElement('div');
      replacements.className = 'd-flex flex-wrap gap-1';

      match.replacements.forEach(r => {
        const btn = document.createElement('button');
        btn.type        = 'button';
        btn.className   = 'btn btn-sm btn-outline-primary';
        btn.textContent = r;
        btn.addEventListener('click', () => this._applyReplacement(match, r));
        replacements.appendChild(btn);
      });

      content.appendChild(replacements);
    }

    body.appendChild(comment);
    body.appendChild(document.createElement('hr'));

    const dismissBtn = document.createElement('button');
    dismissBtn.type      = 'button';
    dismissBtn.className = 'btn btn-sm btn-outline-secondary';
    dismissBtn.innerHTML = '<i class="fa-solid fa-xmark me-1"></i>Dismiss';
    dismissBtn.addEventListener('click', () => this._dismiss(match));
    body.appendChild(dismissBtn);

    new bootstrap.Offcanvas(this.panelTarget).show();
  }

  _applyReplacement(match, replacement) {
    const body = new URLSearchParams({
      commentable_type: this.commentableTypeValue,
      commentable_id:   this.commentableIdValue,
      field_name:       match.field_name,
      offset:           match.offset,
      length:           match.length,
      replacement:      replacement
    });

    fetch(this.grammarReplacementsUrlValue, {
      method:  'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': this._csrf(),
        'Accept':       'application/json'
      },
      body: body.toString()
    })
      .then(r => r.json())
      .then(data => {
        bootstrap.Offcanvas.getInstance(this.panelTarget)?.hide();
        this.highlighter.clearHighlights();
        this._refreshContent(data.raw);
      })
      .catch(err => console.error('GrammarCheck: replacement failed:', err));
  }

  _dismiss(match) {
    bootstrap.Offcanvas.getInstance(this.panelTarget)?.hide();
    this.highlighter.dismiss(match);
  }

  _refreshContent(newRaw) {
    const contentEl = this._contentEl();
    contentEl.dataset.content = newRaw;

    fetch(contentEl.dataset.path, {
      method:  'POST',
      headers: {
        'Accept':       'text/html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': this._csrf()
      },
      body: JSON.stringify({ text: newRaw })
    })
      .then(r => r.text())
      .then(html => {
        contentEl.innerHTML = html;
        contentEl.dispatchEvent(new CustomEvent('dradis:liquid-rendered', { bubbles: true }));
      });
  }

  _contentEl() {
    return document.querySelector('[data-behavior~=content-textile]');
  }

  _csrf() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }
}
