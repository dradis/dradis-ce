/*
  GrammarHighlighter

  Renders grammar/style suggestion marks on the rendered HTML content.
  Each match is wrapped in a <mark class="grammar-suggestion-highlight">
  element. Clicking a mark calls coordinator.showSuggestion(match).
*/

class GrammarHighlighter extends BaseHighlighter {
  constructor(contentElement, coordinator, storageKey) {
    super(contentElement, coordinator);
    this.storageKey = storageKey;
    this.dismissed  = this._loadDismissed();
  }

  highlight(matches) {
    this._clearHighlights('grammar-suggestion-highlight');
    const nextFrom = new Map();
    matches.forEach(match => {
      if (!this.dismissed.has(this._key(match))) {
        this._highlightMatch(match, nextFrom);
      }
    });
  }

  dismiss(match) {
    this.dismissed.add(this._key(match));
    this._saveDismissed();
    this.contentEl.querySelectorAll(`[data-match-key="${this._key(match)}"]`).forEach(mark => {
      this._removeMark(mark);
    });
  }

  _highlightMatch(match, nextFrom = new Map()) {
    if (!match.exact) return;

    const fromIndex = nextFrom.get(match.exact) || 0;
    const segments  = this._findTextInNodes(this._getTextNodes(), match.exact, fromIndex);
    if (segments.length === 0) return;

    const combined = this.contentEl.innerText;
    const matchPos = combined.indexOf(match.exact, fromIndex);
    if (matchPos !== -1) nextFrom.set(match.exact, matchPos + match.exact.length);

    const marks = this._wrapSegments(segments, match);
    marks.forEach(mark => {
      mark.addEventListener('click', e => {
        e.preventDefault();
        this.coordinator.showSuggestion(match, mark);
      });
    });
  }

  _createMark(match) {
    const mark = document.createElement('mark');
    mark.className        = 'grammar-suggestion-highlight';
    mark.dataset.behavior = 'grammar-suggestion-highlight';
    mark.dataset.matchKey = this._key(match);
    return mark;
  }

  // Uses textContent concatenation instead of innerText to avoid block-boundary \n mismatches.
  _findTextInNodes(textNodes, searchText) {
    let offset = 0;
    const nodeMap = [];

    for (const node of textNodes) {
      const len = node.textContent.length;
      nodeMap.push({ node, startIndex: offset, endIndex: offset + len });
      offset += len;
    }

    const combined = nodeMap.map(e => e.node.textContent).join('');
    const matchIndex = combined.indexOf(searchText);
    if (matchIndex === -1) return [];

    const matchEnd = matchIndex + searchText.length;
    const segments = [];

    for (const entry of nodeMap) {
      if (entry.endIndex <= matchIndex) continue;
      if (entry.startIndex >= matchEnd) break;
      segments.push({
        node:        entry.node,
        startOffset: Math.max(matchIndex, entry.startIndex) - entry.startIndex,
        endOffset:   Math.min(matchEnd, entry.endIndex) - entry.startIndex
      });
    }

    return segments;
  }

  _key(match) {
    return `${match.field_name}:${match.offset}:${match.exact}`;
  }

  _loadDismissed() {
    if (!this.storageKey) return new Set();
    try {
      const stored = localStorage.getItem(this.storageKey);
      return stored ? new Set(JSON.parse(stored)) : new Set();
    } catch {
      return new Set();
    }
  }

  _saveDismissed() {
    if (!this.storageKey) return;
    try {
      localStorage.setItem(this.storageKey, JSON.stringify([...this.dismissed]));
    } catch {
      // localStorage may be unavailable (private browsing, storage full)
    }
  }
}

window.GrammarHighlighter = GrammarHighlighter;
