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

    this.highlighter ||= new GrammarHighlighter(contentEl, this);

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
      .then(r => r.json())
      .then(matches => this.highlighter.highlight(matches))
      .catch(err => console.warn('GrammarCheck: check failed:', err));
  }

  showSuggestion(match) {
    this.panelBodyTarget.innerHTML = this._buildPanelHTML(match);

    this.panelBodyTarget.querySelectorAll('[data-grammar-action=accept]').forEach(btn => {
      btn.addEventListener('click', () => this._applyReplacement(match, btn.dataset.replacement));
    });

    this.panelBodyTarget.querySelector('[data-grammar-action=dismiss]')
      ?.addEventListener('click', () => this._dismiss(match));

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

  _buildPanelHTML(match) {
    let html = `<blockquote class="fs-6 border-start border-3 ps-3 text-body-secondary mb-3">${this._esc(match.exact)}</blockquote>`;

    html += `
      <div class="inline-thread-comment py-2">
        <div class="d-flex">
          <div class="me-2 flex-shrink-0" style="width:30px;text-align:center;">
            <i class="fa-solid fa-spell-check text-muted mt-1"></i>
          </div>
          <div class="w-100">
            <div class="mb-1"><span class="fw-semibold small">LanguageTool</span></div>
            <div class="content">
              <p class="mb-2">${this._esc(match.message)}</p>`;

    if (match.replacements?.length) {
      html += `<div class="d-flex flex-wrap gap-1">`;
      match.replacements.forEach(r => {
        html += `<button class="btn btn-sm btn-outline-primary" data-grammar-action="accept" data-replacement="${this._escAttr(r)}">${this._esc(r)}</button>`;
      });
      html += `</div>`;
    }

    html += `
            </div>
          </div>
        </div>
      </div>
      <hr>
      <button class="btn btn-sm btn-outline-secondary" data-grammar-action="dismiss">
        <i class="fa-solid fa-xmark me-1"></i>Dismiss
      </button>`;

    return html;
  }

  _contentEl() {
    return document.querySelector('[data-behavior~=content-textile]');
  }

  _csrf() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }

  _esc(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  _escAttr(str) {
    return String(str).replace(/"/g, '&quot;');
  }
}
