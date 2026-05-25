import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values  = {
    commentableType:        String,
    commentableId:          String,
    grammarCheckUrl:        String,
    grammarReplacementsUrl: String
  }

  connect() {
    this.highlighter    = null;
    this._activePopover = null;
    this._activeMark    = null;

    const contentEl = this._contentEl();
    if (contentEl) {
      this._onLiquidRendered = () => this._fetchAndHighlight();
      contentEl.addEventListener('dradis:liquid-rendered', this._onLiquidRendered);
    } else {
      this._watchPreviewPane();
    }
  }

  disconnect() {
    this._contentEl()?.removeEventListener('dradis:liquid-rendered', this._onLiquidRendered);
    this._destroyPopover();
    if (this._previewObserver) {
      this._previewObserver.disconnect();
      this._previewObserver = null;
    }
  }

  // ----------------------------------------------------------------- private

  _fetchAndHighlight() {
    const contentEl = this._contentEl();
    if (!contentEl) return;

    const storageKey = `grammar_dismissed:${this.commentableTypeValue}:${this.commentableIdValue}`;
    this.highlighter ||= new GrammarHighlighter(contentEl, this, storageKey);

    this._fetchMatches().then(matches => this.highlighter.highlight(matches));
  }

  _watchPreviewPane() {
    const editorEl = document.getElementById('issues_editor');
    if (!editorEl) return;

    let debounceTimer = null;

    this._previewObserver = new MutationObserver((mutations) => {
      const previewEl = editorEl.querySelector('.textile-preview');

      // Ignore mutations caused by our own mark insertion/removal inside the preview
      if (previewEl && mutations.every(m => previewEl.contains(m.target))) return;

      if (!previewEl || !previewEl.children.length) return;

      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => this._fetchAndHighlightPreview(previewEl), 300);
    });

    this._previewObserver.observe(editorEl, { childList: true, subtree: true });
  }

  _fetchAndHighlightPreview(previewEl) {
    this._destroyPopover();

    const storageKey = `grammar_dismissed:${this.commentableTypeValue}:${this.commentableIdValue}`;
    this.highlighter = new GrammarHighlighter(previewEl, this, storageKey);

    this._fetchMatches().then(matches => this.highlighter.highlight(matches));
  }

  _fetchMatches() {
    const body = new URLSearchParams({
      commentable_type: this.commentableTypeValue,
      commentable_id:   this.commentableIdValue
    });

    const textarea = document.querySelector('textarea.textile');
    if (textarea) body.set('text', textarea.value);

    return fetch(this.grammarCheckUrlValue, {
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
      .catch(err => {
        console.warn('GrammarCheck: check failed:', err);
        return [];
      });
  }

  showSuggestion(match, markEl) {
    this._destroyPopover();

    const content = document.createElement('div');

    const quote = document.createElement('blockquote');
    quote.className   = 'fs-6 border-start border-3 ps-3 text-body-secondary mb-3';
    quote.textContent = match.exact;
    content.appendChild(quote);

    const message = document.createElement('p');
    message.className   = 'mb-2';
    message.textContent = match.message;
    content.appendChild(message);

    if (match.replacements?.length) {
      const replacements = document.createElement('div');
      replacements.className = 'd-flex flex-wrap gap-1 mb-3';

      match.replacements.forEach(r => {
        if (this.grammarReplacementsUrlValue) {
          const btn = document.createElement('button');
          btn.type        = 'button';
          btn.className   = 'btn btn-sm btn-outline-primary';
          btn.textContent = r;
          btn.addEventListener('click', () => this._applyReplacement(match, r));
          replacements.appendChild(btn);
        } else {
          const badge = document.createElement('span');
          badge.className   = 'badge text-bg-secondary';
          badge.textContent = r;
          replacements.appendChild(badge);
        }
      });

      content.appendChild(replacements);
    }

    const dismissBtn = document.createElement('button');
    dismissBtn.type      = 'button';
    dismissBtn.className = 'btn btn-sm btn-outline-secondary';
    dismissBtn.innerHTML = '<i class="fa-solid fa-xmark me-1"></i>Dismiss';
    dismissBtn.addEventListener('click', () => this._dismiss(match));
    content.appendChild(dismissBtn);

    this._activePopover = new bootstrap.Popover(markEl, {
      content:   content,
      html:      true,
      trigger:   'manual',
      placement: 'bottom',
      title:     '<i class="fa-solid fa-spell-check me-1"></i> Grammar Suggestion'
    });
    this._activeMark = markEl;
    this._activePopover.show();
  }

  _applyReplacement(match, replacement) {
    const body = new URLSearchParams({
      commentable_type: this.commentableTypeValue,
      commentable_id:   this.commentableIdValue,
      field_name:       match.field_name,
      offset:           match.offset,
      length:           match.length,
      exact:            match.exact,
      replacement:      replacement
    });

    const textarea = document.querySelector('textarea.textile');
    if (textarea) {
      body.set('text', textarea.value);
      if (!this._contentEl()) body.set('persist', 'false');
    }

    fetch(this.grammarReplacementsUrlValue, {
      method:  'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': this._csrf(),
        'Accept':       'application/json'
      },
      body: body.toString()
    })
      .then(r => {
        if (r.status === 409) {
          this._destroyPopover();
          this.highlighter.highlight([]);
          return null;
        }
        if (!r.ok) throw new Error(`Grammar replacement failed: ${r.status}`);
        return r.json();
      })
      .then(data => {
        if (!data) return;
        this._destroyPopover();
        this.highlighter.highlight([]);
        this._refreshContent(data.raw);
      })
      .catch(err => console.error('GrammarCheck: replacement failed:', err));
  }

  _dismiss(match) {
    this._destroyPopover();
    this.highlighter.dismiss(match);
  }

  _destroyPopover() {
    if (this._activePopover) {
      this._activePopover.dispose();
      this._activePopover = null;
      this._activeMark    = null;
    }
  }

  _refreshContent(newRaw) {
    const contentEl = this._contentEl();

    if (contentEl) {
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
    } else {
      const textarea = document.querySelector('textarea.textile');
      if (!textarea) return;
      textarea.value = newRaw;
      $(textarea).trigger('load-preview');
    }
  }

  _contentEl() {
    return document.querySelector('[data-behavior~=content-textile]');
  }

  _csrf() {
    return document.querySelector('meta[name="csrf-token"]')?.content;
  }
}
