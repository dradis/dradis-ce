/*
  BaseHighlighter

  Base class for text-range highlighters. Provides shared helpers for
  walking text nodes, locating a search string across them, wrapping
  matched segments with <mark> elements, and unwrapping those marks.

  Subclasses must implement _createMark(item) to return a configured
  <mark> element, and call _clearHighlights(behaviorName) /
  _wrapSegments(segments, item) with their own behavior name.
*/

class BaseHighlighter {
  constructor(contentElement, coordinator) {
    this.contentEl = contentElement;
    this.coordinator = coordinator;
  }

  // Unwrap a single <mark> element, reinserting its children in place.
  _removeMark(mark) {
    const parent = mark.parentNode;
    while (mark.firstChild) parent.insertBefore(mark.firstChild, mark);
    parent.removeChild(mark);
    parent.normalize();
  }

  _clearHighlights(behaviorName) {
    this.contentEl
      .querySelectorAll(`[data-behavior~=${behaviorName}]`)
      .forEach(mark => this._removeMark(mark));
  }

  _getTextNodes() {
    const nodes = [];
    const walker = document.createTreeWalker(this.contentEl, NodeFilter.SHOW_TEXT, null, false);
    let node;
    while ((node = walker.nextNode())) nodes.push(node);
    return nodes;
  }

  // Returns an array of { node, startOffset, endOffset } segments —
  // one per text node that overlaps the match. Each segment stays
  // within a single text node so surroundContents works safely.
  //
  // Uses innerText as the combined string because anchor.exact comes
  // from getSelection().toString() which mirrors innerText behavior
  // (inserting \n at block boundaries and <br> elements).
  _findTextInNodes(textNodes, searchText, fromIndex = 0) {
    const combined = this.contentEl.innerText;
    let matchIndex = combined.indexOf(searchText, fromIndex);
    let matchEnd;

    if (matchIndex !== -1) {
      matchEnd = matchIndex + searchText.length;
    } else {
      // Cross-browser: anchor.exact may use different whitespace than
      // the current browser's innerText (e.g. Safari uses spaces where
      // Firefox uses \n\n around block elements). Fuzzy-match whitespace.
      const result = fuzzyIndexOf(combined, searchText, fromIndex);
      if (!result) return [];
      matchIndex = result.start;
      matchEnd = result.end;
    }

    const nodeMap = [];
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
      var segEnd = Math.min(matchEnd, entry.endIndex) - entry.startIndex;
      segments.push({ node: entry.node, startOffset: segStart, endOffset: segEnd });
    }

    return segments;
  }

  // Wrap each matched segment with a <mark> returned by _createMark(item).
  // Processes in reverse order to avoid invalidating DOM offsets.
  _wrapSegments(segments, item) {
    const marks = [];

    for (let i = segments.length - 1; i >= 0; i--) {
      const seg = segments[i];
      try {
        const range = document.createRange();
        range.setStart(seg.node, seg.startOffset);
        range.setEnd(seg.node, seg.endOffset);

        const mark = this._createMark(item);
        range.surroundContents(mark);
        marks.push(mark);
      } catch (e) {
        console.warn(`${this.constructor.name}: could not wrap segment:`, e.message);
      }
    }

    return marks;
  }
}
