/*
  InlineThreadHighlighter

  Renders highlight marks on the rendered HTML content for
  existing inline comment threads. Uses TreeWalker to find
  matching text nodes and wraps them with <mark> elements.

  Usage:
    var highlighter = new InlineThreadHighlighter(contentElement, coordinator);
    highlighter.highlight(threads);

  Where `contentElement` is the [data-behavior=content-textile] element,
  `coordinator` is an InlineThreadTurbo instance, and `threads` is the
  JSON array from the inline_threads index endpoint.
*/

class InlineThreadHighlighter {
  constructor(contentElement, coordinator) {
    this.contentEl = contentElement;
    this.coordinator = coordinator;
  }

  highlight(threads) {
    this.clearHighlights();

    threads.forEach(thread => {
      this.highlightThread(thread);
    });
  }

  highlightThread(thread) {
    const exact = thread.anchor.exact;
    if (!exact) return;

    const textNodes = this.getTextNodes();
    const segments = this.findTextInNodes(textNodes, exact);

    if (segments.length === 0) return;

    const marks = this.wrapSegments(segments, thread);

    // Click handler to open thread in Turbo Frame panel
    marks.forEach(mark => {
      mark.addEventListener('click', (e) => {
        e.preventDefault();
        this.coordinator.showThread(thread.id);
      });
    });
  }

  // Wrap each matched text node segment with a <mark> element.
  // Processes in reverse order to avoid invalidating DOM offsets.
  wrapSegments(segments, thread) {
    const marks = [];

    for (let i = segments.length - 1; i >= 0; i--) {
      const seg = segments[i];

      try {
        const range = document.createRange();
        range.setStart(seg.node, seg.startOffset);
        range.setEnd(seg.node, seg.endOffset);

        const mark = document.createElement('mark');
        mark.className = 'inline-thread-highlight';
        mark.dataset.behavior = 'inline-thread-highlight';
        mark.dataset.threadId = thread.id;
        mark.dataset.commentCount = thread.comments.length;

        if (thread.status === 'resolved') {
          mark.classList.add('resolved');
        }
        if (thread.outdated) {
          mark.classList.add('outdated');
        }

        range.surroundContents(mark);
        marks.push(mark);
      } catch (e) {
        console.warn('Could not highlight segment for thread ' + thread.id + ':', e.message);
      }
    }

    return marks;
  }

  clearHighlights() {
    const marks = this.contentEl.querySelectorAll('[data-behavior~=inline-thread-highlight]');
    marks.forEach(mark => {
      const parent = mark.parentNode;
      while (mark.firstChild) {
        parent.insertBefore(mark.firstChild, mark);
      }
      parent.removeChild(mark);
      parent.normalize();
    });
  }

  getTextNodes() {
    const textNodes = [];
    const walker = document.createTreeWalker(
      this.contentEl,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );

    let node;
    while ((node = walker.nextNode())) {
      textNodes.push(node);
    }

    return textNodes;
  }

  // Returns an array of { node, startOffset, endOffset } segments —
  // one per text node that overlaps the match. Each segment stays
  // within a single text node so surroundContents works safely.
  //
  // Uses innerText as the combined string because anchor.exact comes
  // from getSelection().toString() which mirrors innerText behavior
  // (inserting \n at block boundaries and <br> elements).
  findTextInNodes(textNodes, searchText) {
    const combined = this.contentEl.innerText;
    let matchIndex = combined.indexOf(searchText);
    let matchEnd;

    if (matchIndex !== -1) {
      matchEnd = matchIndex + searchText.length;
    } else {
      // Cross-browser: anchor.exact may use different whitespace than
      // the current browser's innerText (e.g. Safari uses spaces where
      // Firefox uses \n\n around block elements). Fuzzy-match whitespace.
      const result = this.fuzzyIndexOf(combined, searchText);
      if (!result) return [];
      matchIndex = result.start;
      matchEnd = result.end;
    }

    // Map each text node to its position within innerText
    const nodeMap = [];
    let searchFrom = 0;

    for (var i = 0; i < textNodes.length; i++) {
      var content = textNodes[i].textContent;
      if (!content.trim()) continue;

      var pos = combined.indexOf(content, searchFrom);
      if (pos === -1) continue;

      nodeMap.push({
        node: textNodes[i],
        startIndex: pos,
        endIndex: pos + content.length
      });
      searchFrom = pos + content.length;
    }

    const segments = [];

    for (var j = 0; j < nodeMap.length; j++) {
      var entry = nodeMap[j];

      // Skip nodes entirely before the match
      if (entry.endIndex <= matchIndex) continue;

      // Stop after nodes entirely after the match
      if (entry.startIndex >= matchEnd) break;

      var segStart = Math.max(matchIndex, entry.startIndex) - entry.startIndex;
      var segEnd = Math.min(matchEnd, entry.endIndex) - entry.startIndex;

      segments.push({
        node: entry.node,
        startOffset: segStart,
        endOffset: segEnd
      });
    }

    return segments;
  }

  // Find `needle` in `haystack` allowing whitespace runs in the needle
  // to match any whitespace run in the haystack. Returns { start, end }
  // positions in the original haystack, or null.
  fuzzyIndexOf(haystack, needle) {
    const parts = needle.split(/\s+/).map(
      s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    );
    if (parts.length < 2) return null;

    const pattern = new RegExp(parts.join('\\s+'));
    const match = haystack.match(pattern);
    if (!match) return null;

    return { start: match.index, end: match.index + match[0].length };
  }
}
