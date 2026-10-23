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
    this.dismissed = this._loadDismissed();
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

    const key = `${match.field_name}:${match.exact}`;
    const fromIndex = nextFrom.get(key) || 0;
    const textNodes = this._getFieldTextNodes(match.field_name);
    const segments = this._findTextInNodes(textNodes, match.exact, fromIndex);
    if (segments.length === 0) return;

    const combined = textNodes.map(n => n.textContent).join('');
    const matchPos = combined.indexOf(match.exact, fromIndex);
    if (matchPos !== -1) nextFrom.set(key, matchPos + match.exact.length);

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
    mark.className = 'grammar-suggestion-highlight';
    mark.dataset.behavior = 'grammar-suggestion-highlight';
    mark.dataset.matchKey = this._key(match);
    return mark;
  }

  _getFieldTextNodes(fieldName) {
    const headings = Array.from(this.contentEl.querySelectorAll('h5'));
    const headingIndex = headings.findIndex(h => h.textContent.trim() === fieldName);
    if (headingIndex === -1) return this._getTextNodes();

    const startHeading = headings[headingIndex];
    const endHeading = headings[headingIndex + 1] || null;

    return this._getTextNodes().filter(node => {
      const afterStart = startHeading.compareDocumentPosition(node) & Node.DOCUMENT_POSITION_FOLLOWING;
      if (!afterStart) return false;
      if (!endHeading) return true;
      return !!(endHeading.compareDocumentPosition(node) & Node.DOCUMENT_POSITION_PRECEDING);
    });
  }

  // Uses textContent concatenation instead of innerText to avoid block-boundary \n mismatches.
  _findTextInNodes(textNodes, searchText, fromIndex = 0) {
    let offset = 0;
    const nodeMap = [];

    for (const node of textNodes) {
      const len = node.textContent.length;
      nodeMap.push({ node, startIndex: offset, endIndex: offset + len });
      offset += len;
    }

    const combined = nodeMap.map(e => e.node.textContent).join('');
    const matchIndex = combined.indexOf(searchText, fromIndex);
    if (matchIndex === -1) return [];

    const matchEnd = matchIndex + searchText.length;
    const segments = [];

    for (const entry of nodeMap) {
      if (entry.endIndex <= matchIndex) continue;
      if (entry.startIndex >= matchEnd) break;
      segments.push({
        node: entry.node,
        startOffset: Math.max(matchIndex, entry.startIndex) - entry.startIndex,
        endOffset: Math.min(matchEnd, entry.endIndex) - entry.startIndex
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
