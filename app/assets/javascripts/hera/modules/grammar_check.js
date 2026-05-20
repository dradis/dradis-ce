/*
  GrammarCheck

  Coordinates automatic grammar and style checking via LanguageTool.
  Initialises on turbo:load when [data-behavior~=grammar-container] is
  present. Triggers a check after the issue content renders, highlights
  matches using GrammarHighlighter (purple underline), and shows
  suggestions in an offcanvas panel styled like an inline thread.

  Follows the InlineThreadTurbo pattern.
*/

document.addEventListener('turbo:load', function () {
  const container = document.querySelector('[data-behavior~=grammar-container]');
  if (!container) return;

  const contentEl = document.querySelector('[data-behavior~=content-textile]');
  if (!contentEl) return;

  const checker = new GrammarCheck(container, contentEl);

  contentEl.addEventListener('dradis:liquid-rendered', function () {
    checker.fetchAndHighlight();
  });
});

class GrammarCheck {
  constructor(container, contentEl) {
    this.container        = container;
    this.contentEl        = contentEl;
    this.highlighter      = new GrammarHighlighter(contentEl, this);
    this.panel            = document.querySelector('[data-behavior~=grammar-panel]');
    this.panelBody        = document.querySelector('[data-behavior~=grammar-panel-body]');
    this.checkUrl         = container.dataset.grammarCheckUrl;
    this.replacementsUrl  = container.dataset.grammarReplacementsUrl;
    this.commentableType  = container.dataset.commentableType;
    this.commentableId    = container.dataset.commentableId;
  }

  fetchAndHighlight() {
    const body = new URLSearchParams({
      commentable_type: this.commentableType,
      commentable_id:   this.commentableId
    });

    fetch(this.checkUrl, {
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
    this.panelBody.innerHTML = this._buildPanelHTML(match);

    this.panelBody.querySelectorAll('[data-behavior~=grammar-accept]').forEach(btn => {
      btn.addEventListener('click', () => this._applyReplacement(match, btn.dataset.replacement));
    });

    this.panelBody.querySelector('[data-behavior~=grammar-dismiss]')
      ?.addEventListener('click', () => this._dismiss(match));

    new bootstrap.Offcanvas(this.panel).show();
  }

  _applyReplacement(match, replacement) {
    const body = new URLSearchParams({
      commentable_type: this.commentableType,
      commentable_id:   this.commentableId,
      field_name:       match.field_name,
      offset:           match.offset,
      length:           match.length,
      replacement:      replacement
    });

    fetch(this.replacementsUrl, {
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
        bootstrap.Offcanvas.getInstance(this.panel)?.hide();
        this.highlighter.clearHighlights();
        this._refreshContent(data.raw);
      })
      .catch(err => console.error('GrammarCheck: replacement failed:', err));
  }

  _dismiss(match) {
    bootstrap.Offcanvas.getInstance(this.panel)?.hide();
    this.highlighter.dismiss(match);
  }

  _refreshContent(newRaw) {
    this.contentEl.dataset.content = newRaw;

    fetch(this.contentEl.dataset.path, {
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
        this.contentEl.innerHTML = html;
        this.contentEl.dispatchEvent(new CustomEvent('dradis:liquid-rendered', { bubbles: true }));
      });
  }

  _buildPanelHTML(match) {
    let html = `<blockquote class="blockquote fs-6 border-start border-3 ps-3 text-body-secondary mb-3">${this._escHtml(match.exact)}</blockquote>`;

    html += `
      <div class="inline-thread-comment py-2">
        <div class="d-flex">
          <div class="me-2 flex-shrink-0" style="width:30px; text-align:center;">
            <i class="fa-solid fa-spell-check text-muted mt-1"></i>
          </div>
          <div class="w-100">
            <div class="mb-1">
              <span class="fw-semibold small">LanguageTool</span>
            </div>
            <div class="content">
              <p class="mb-2">${this._escHtml(match.message)}</p>`;

    if (match.replacements && match.replacements.length > 0) {
      html += `<div class="d-flex flex-wrap gap-1">`;
      match.replacements.forEach(r => {
        html += `<button class="btn btn-sm btn-outline-primary" data-behavior="grammar-accept" data-replacement="${this._escAttr(r)}">${this._escHtml(r)}</button>`;
      });
      html += `</div>`;
    }

    html += `
            </div>
          </div>
        </div>
      </div>
      <hr>
      <button class="btn btn-sm btn-outline-secondary" data-behavior="grammar-dismiss">
        <i class="fa-solid fa-xmark me-1"></i>Dismiss
      </button>`;

    return html;
  }

  _csrf() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }

  _escHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  _escAttr(str) {
    return String(str).replace(/"/g, '&quot;');
  }
}
