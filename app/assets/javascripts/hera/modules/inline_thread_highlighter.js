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

    threads.forEach(function (thread) {
      this.highlightThread(thread);
    }.bind(this));
  }

  highlightThread(thread) {
    var exact = thread.anchor.exact;
    if (!exact) return;

    var textNodes = this.getTextNodes();
    var segments = this.findTextInNodes(textNodes, exact);

    if (!segments || segments.length === 0) return;

    var marks = this.wrapSegments(segments, thread);

    // Click handler to open thread in Turbo Frame panel
    var coordinator = this.coordinator;
    marks.forEach(function (mark) {
      mark.addEventListener('click', function (e) {
        e.preventDefault();
        coordinator.showThread(thread.id);
      });
    });
  }

  // Wrap each matched text node segment with a <mark> element.
  // Processes in reverse order to avoid invalidating DOM offsets.
  wrapSegments(segments, thread) {
    var marks = [];

    for (var i = segments.length - 1; i >= 0; i--) {
      var seg = segments[i];

      try {
        var range = document.createRange();
        range.setStart(seg.node, seg.startOffset);
        range.setEnd(seg.node, seg.endOffset);

        var mark = document.createElement('mark');
        mark.className = 'inline-thread-highlight';
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
    var marks = this.contentEl.querySelectorAll('mark.inline-thread-highlight');
    marks.forEach(function (mark) {
      var parent = mark.parentNode;
      while (mark.firstChild) {
        parent.insertBefore(mark.firstChild, mark);
      }
      parent.removeChild(mark);
      parent.normalize();
    });
  }

  getTextNodes() {
    var textNodes = [];
    var walker = document.createTreeWalker(
      this.contentEl,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );

    var node;
    while ((node = walker.nextNode())) {
      textNodes.push(node);
    }

    return textNodes;
  }

  // Returns an array of { node, startOffset, endOffset } segments —
  // one per text node that overlaps the match. Each segment stays
  // within a single text node so surroundContents works safely.
  findTextInNodes(textNodes, searchText) {
    var combined = '';
    var nodeMap = [];

    for (var i = 0; i < textNodes.length; i++) {
      var nodeText = textNodes[i].textContent;
      var startIndex = combined.length;
      combined += nodeText;
      nodeMap.push({
        node: textNodes[i],
        startIndex: startIndex,
        endIndex: combined.length
      });
    }

    var matchIndex = combined.indexOf(searchText);
    if (matchIndex === -1) return null;

    var matchEnd = matchIndex + searchText.length;
    var segments = [];

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

    return segments.length > 0 ? segments : null;
  }
}
