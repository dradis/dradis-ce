/*
  GrammarHighlighter

  Renders grammar/style suggestion marks on the rendered HTML content.
  Uses the same text-node walking strategy as InlineThreadHighlighter.
  Each match is wrapped in a <mark class="grammar-suggestion-highlight">
  element. Clicking a mark calls coordinator.showSuggestion(match).
*/

class GrammarHighlighter {
  constructor(contentElement, coordinator) {
    this.contentEl   = contentElement;
    this.coordinator = coordinator;
    this.dismissed   = new Set();
  }

  highlight(matches) {
    this.clearHighlights();
    matches.forEach(match => {
      if (!this.dismissed.has(this._key(match))) {
        this._highlightMatch(match);
      }
    });
  }

  clearHighlights() {
    this.contentEl.querySelectorAll('[data-behavior~=grammar-suggestion-highlight]').forEach(mark => {
      const parent = mark.parentNode;
      while (mark.firstChild) parent.insertBefore(mark.firstChild, mark);
      parent.removeChild(mark);
      parent.normalize();
    });
  }

  dismiss(match) {
    this.dismissed.add(this._key(match));
    this.contentEl.querySelectorAll('[data-behavior~=grammar-suggestion-highlight]').forEach(mark => {
      if (mark.dataset.matchKey === this._key(match)) {
        const parent = mark.parentNode;
        while (mark.firstChild) parent.insertBefore(mark.firstChild, mark);
        parent.removeChild(mark);
        parent.normalize();
      }
    });
  }

  _highlightMatch(match) {
    if (!match.exact) return;

    const segments = this._findTextInNodes(this._getTextNodes(), match.exact);
    if (segments.length === 0) return;

    const marks = this._wrapSegments(segments, match);
    marks.forEach(mark => {
      mark.addEventListener('click', e => {
        e.preventDefault();
        this.coordinator.showSuggestion(match);
      });
    });
  }

  _wrapSegments(segments, match) {
    const marks = [];
    for (let i = segments.length - 1; i >= 0; i--) {
      const seg = segments[i];
      try {
        const range = document.createRange();
        range.setStart(seg.node, seg.startOffset);
        range.setEnd(seg.node, seg.endOffset);

        const mark = document.createElement('mark');
        mark.className        = 'grammar-suggestion-highlight';
        mark.dataset.behavior = 'grammar-suggestion-highlight';
        mark.dataset.matchKey = this._key(match);

        range.surroundContents(mark);
        marks.push(mark);
      } catch (e) {
        console.warn('GrammarHighlighter: could not wrap segment:', e.message);
      }
    }
    return marks;
  }

  _getTextNodes() {
    const nodes  = [];
    const walker = document.createTreeWalker(this.contentEl, NodeFilter.SHOW_TEXT, null, false);
    let node;
    while ((node = walker.nextNode())) nodes.push(node);
    return nodes;
  }

  _findTextInNodes(textNodes, searchText) {
    const combined = this.contentEl.innerText;
    let matchIndex = combined.indexOf(searchText);
    let matchEnd;

    if (matchIndex !== -1) {
      matchEnd = matchIndex + searchText.length;
    } else {
      const result = fuzzyIndexOf(combined, searchText);
      if (!result) return [];
      matchIndex = result.start;
      matchEnd   = result.end;
    }

    const nodeMap  = [];
    let searchFrom = 0;
    for (var i = 0; i < textNodes.length; i++) {
      var content = textNodes[i].textContent;
      if (!content.trim()) continue;
      var pos = combined.indexOf(content, searchFrom);
      if (pos === -1) continue;
      nodeMap.push({ node: textNodes[i], startIndex: pos, endIndex: pos + content.length });
      searchFrom = pos + content.length;
    }

    const segments = [];
    for (var j = 0; j < nodeMap.length; j++) {
      var entry = nodeMap[j];
      if (entry.endIndex <= matchIndex) continue;
      if (entry.startIndex >= matchEnd) break;
      var segStart = Math.max(matchIndex, entry.startIndex) - entry.startIndex;
      var segEnd   = Math.min(matchEnd, entry.endIndex) - entry.startIndex;
      segments.push({ node: entry.node, startOffset: segStart, endOffset: segEnd });
    }
    return segments;
  }

  _key(match) {
    return `${match.field_name}:${match.offset}:${match.length}`;
  }
}

window.GrammarHighlighter = GrammarHighlighter;
