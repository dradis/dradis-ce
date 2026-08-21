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

class InlineThreadHighlighter extends BaseHighlighter {
  highlight(threads) {
    this._clearHighlights('inline-thread-highlight');

    threads.forEach(thread => {
      this.highlightThread(thread);
    });
  }

  highlightThread(thread) {
    const exact = thread.anchor.exact;
    if (!exact) return;

    const segments = this._findTextInNodes(this._getTextNodes(), exact);
    if (segments.length === 0) return;

    const marks = this._wrapSegments(segments, thread);

    // Click handler to open thread in Turbo Frame panel
    marks.forEach(mark => {
      mark.addEventListener('click', (e) => {
        e.preventDefault();
        this.coordinator.showThread(thread.id);
      });
    });
  }

  _createMark(thread) {
    const mark = document.createElement('mark');
    mark.className = 'inline-thread-highlight';
    mark.dataset.behavior = 'inline-thread-highlight';
    mark.dataset.threadId = thread.id;
    mark.dataset.commentCount = thread.comments.length;

    if (thread.status === 'resolved') mark.classList.add('resolved');
    if (thread.outdated) mark.classList.add('outdated');

    return mark;
  }
}
