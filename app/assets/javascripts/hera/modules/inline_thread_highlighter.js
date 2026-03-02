/*
  InlineThreadHighlighter

  Renders highlight marks on the rendered HTML content for
  existing inline comment threads. Uses TreeWalker to find
  matching text nodes and wraps them with <mark> elements.

  Usage:
    var highlighter = new InlineThreadHighlighter(contentElement, panel);
    highlighter.highlight(threads);

  Where `contentElement` is the [data-behavior=content-textile] element,
  `panel` is an InlineThreadPanel instance, and `threads` is the
  JSON array from the inline_threads index endpoint.
*/

class InlineThreadHighlighter {
  constructor(contentElement, panel) {
    this.contentEl = contentElement;
    this.panel = panel;
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
    var matchInfo = this.findTextInNodes(textNodes, exact);

    if (!matchInfo) return;

    try {
      var range = document.createRange();
      range.setStart(matchInfo.startNode, matchInfo.startOffset);
      range.setEnd(matchInfo.endNode, matchInfo.endOffset);

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

      // Click handler to open thread panel
      var panel = this.panel;
      mark.addEventListener('click', function (e) {
        e.preventDefault();
        panel.openExistingThread(thread);
      });
    } catch (e) {
      // surroundContents can fail if the range spans multiple elements.
      // In that case, we skip this highlight gracefully.
      console.warn('Could not highlight thread ' + thread.id + ':', e.message);
    }
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

  findTextInNodes(textNodes, searchText) {
    // Build a combined text string with node boundaries tracked
    var combined = '';
    var nodeMap = []; // { node, startIndex, endIndex }

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

    // Find the start node and offset
    var startNode = null, startOffset = 0;
    var endNode = null, endOffset = 0;

    for (var j = 0; j < nodeMap.length; j++) {
      var entry = nodeMap[j];

      if (!startNode && matchIndex >= entry.startIndex && matchIndex < entry.endIndex) {
        startNode = entry.node;
        startOffset = matchIndex - entry.startIndex;
      }

      if (matchEnd > entry.startIndex && matchEnd <= entry.endIndex) {
        endNode = entry.node;
        endOffset = matchEnd - entry.startIndex;
        break;
      }
    }

    if (!startNode || !endNode) return null;

    // surroundContents requires start and end in the same node
    if (startNode !== endNode) return null;

    return {
      startNode: startNode,
      startOffset: startOffset,
      endNode: endNode,
      endOffset: endOffset
    };
  }
}
