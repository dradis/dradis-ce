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

    if (!segments || segments.length === 0) return;

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
  findTextInNodes(textNodes, searchText) {
    let combined = '';
    const nodeMap = [];

    for (let i = 0; i < textNodes.length; i++) {
      const nodeText = textNodes[i].textContent;
      const startIndex = combined.length;
      combined += nodeText;
      nodeMap.push({
        node: textNodes[i],
        startIndex: startIndex,
        endIndex: combined.length
      });
    }

    const matchIndex = combined.indexOf(searchText);
    if (matchIndex === -1) return null;

    const matchEnd = matchIndex + searchText.length;
    const segments = [];

    for (let j = 0; j < nodeMap.length; j++) {
      const entry = nodeMap[j];

      // Skip nodes entirely before the match
      if (entry.endIndex <= matchIndex) continue;

      // Stop after nodes entirely after the match
      if (entry.startIndex >= matchEnd) break;

      const segStart = Math.max(matchIndex, entry.startIndex) - entry.startIndex;
      const segEnd = Math.min(matchEnd, entry.endIndex) - entry.startIndex;

      segments.push({
        node: entry.node,
        startOffset: segStart,
        endOffset: segEnd
      });
    }

    return segments.length > 0 ? segments : null;
  }
}
