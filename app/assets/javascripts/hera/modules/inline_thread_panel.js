/*
  InlineThreadPanel

  A slide-out panel on the right side of the QA issue show page.
  Displays inline thread details, comments, and forms for replying,
  resolving, and reopening threads.

  Usage:
    var panel = new InlineThreadPanel(panelElement, options);

  Where `panelElement` is [data-behavior=inline-thread-panel]
  and `options` includes { csrfToken, currentUserId }.
*/

class InlineThreadPanel {
  constructor(panelElement, options) {
    this.$panel = $(panelElement);
    this.csrfToken = options.csrfToken;
    this.currentUserId = options.currentUserId;

    this.buildPanel();
    this.bindEvents();
  }

  buildPanel() {
    this.$panel.html(
      '<div class="inline-thread-panel-header d-flex justify-content-between align-items-center p-3 border-bottom">' +
        '<h6 class="mb-0">Inline Comment</h6>' +
        '<button type="button" class="btn-close" data-behavior="close-inline-panel" aria-label="Close"></button>' +
      '</div>' +
      '<div class="inline-thread-panel-body p-3"></div>'
    );
    this.$body = this.$panel.find('.inline-thread-panel-body');
  }

  bindEvents() {
    var that = this;

    this.$panel.on('click', '[data-behavior~=close-inline-panel]', function () {
      that.close();
    });

    $(document).on('keydown.inlinePanel', function (e) {
      if (e.key === 'Escape' && that.$panel.hasClass('open')) {
        that.close();
      }
    });
  }

  open() {
    this.$panel.addClass('open');
  }

  close() {
    this.$panel.removeClass('open');
    this.$body.empty();
  }

  openNewThread(anchor, createPath) {
    var that = this;

    this.$body.html(
      '<div class="thread-quoted-text mb-3">' +
        '<label class="form-label text-muted small">Selected text</label>' +
        '<blockquote class="border-start border-3 border-primary ps-3 text-muted fst-italic">' +
          this.escapeHtml(anchor.exact) +
        '</blockquote>' +
      '</div>' +
      '<form data-behavior="new-inline-thread-form">' +
        '<div class="mb-3">' +
          '<textarea class="form-control" name="comment[content]" rows="4" placeholder="Write a comment..." required></textarea>' +
        '</div>' +
        '<div class="d-flex justify-content-end">' +
          '<button type="button" class="btn btn-sm btn-secondary me-2" data-behavior="close-inline-panel">Cancel</button>' +
          '<button type="submit" class="btn btn-sm btn-primary">Comment</button>' +
        '</div>' +
      '</form>'
    );

    this.$body.find('form').on('submit', function (e) {
      e.preventDefault();
      var $form = $(this);
      var content = $form.find('textarea').val();
      if (!content.trim()) return;

      var $submitBtn = $form.find('[type=submit]');
      $submitBtn.attr('disabled', 'disabled').text('Submitting...');

      $.ajax({
        url: createPath,
        method: 'POST',
        dataType: 'script',
        headers: { 'X-CSRF-Token': that.csrfToken },
        data: {
          inline_comment_thread: { anchor: anchor },
          comment: { content: content }
        }
      }).fail(function () {
        $submitBtn.removeAttr('disabled').text('Comment');
        alert('Failed to create comment thread.');
      });
    });

    this.open();
    this.$body.find('textarea').focus();
  }

  openExistingThread(thread) {
    var that = this;
    var commentsHtml = '';

    thread.comments.forEach(function (comment) {
      commentsHtml += that.renderComment(comment);
    });

    var statusBadge = '';
    if (thread.status === 'resolved') {
      statusBadge = '<span class="badge bg-success ms-2">Resolved</span>';
    }
    if (thread.outdated) {
      statusBadge += '<span class="badge bg-warning text-dark ms-2">Outdated</span>';
    }

    this.$body.html(
      '<div class="thread-quoted-text mb-3">' +
        '<label class="form-label text-muted small">Quoted text' + statusBadge + '</label>' +
        '<blockquote class="border-start border-3 border-primary ps-3 text-muted fst-italic">' +
          this.escapeHtml(thread.anchor.exact) +
        '</blockquote>' +
      '</div>' +
      '<div class="thread-comments mb-3" data-behavior="thread-comment-list">' +
        commentsHtml +
      '</div>' +
      '<div class="thread-actions mb-3">' +
        this.renderResolutionButton(thread) +
      '</div>' +
      '<form data-behavior="inline-thread-reply-form" data-thread-id="' + thread.id + '">' +
        '<div class="mb-3">' +
          '<textarea class="form-control" name="comment[content]" rows="3" placeholder="Reply..."></textarea>' +
        '</div>' +
        '<div class="d-flex justify-content-end">' +
          '<button type="submit" class="btn btn-sm btn-primary">Reply</button>' +
        '</div>' +
      '</form>'
    );

    this.bindThreadActions(thread);
    this.open();
  }

  renderComment(comment) {
    return '<div class="inline-thread-comment py-2 border-bottom" data-comment-id="' + comment.id + '">' +
      '<div class="d-flex justify-content-between">' +
        '<span class="fw-bold small">' + this.escapeHtml(comment.user.name) + '</span>' +
        '<span class="text-muted small">' + this.formatDate(comment.created_at) + '</span>' +
      '</div>' +
      '<div class="mt-1 small">' + comment.content + '</div>' +
    '</div>';
  }

  renderResolutionButton(thread) {
    if (thread.status === 'open') {
      return '<button class="btn btn-sm btn-outline-success" data-behavior="resolve-thread">' +
        '<i class="fa-solid fa-check me-1"></i>Resolve' +
      '</button>';
    } else {
      return '<button class="btn btn-sm btn-outline-secondary" data-behavior="reopen-thread">' +
        '<i class="fa-solid fa-rotate-left me-1"></i>Reopen' +
      '</button>';
    }
  }

  bindThreadActions(thread) {
    var that = this;
    var basePath = this.$panel.closest('.col-12')
      .find('[data-behavior~=inline-threads-container]')
      .data('inline-threads-create-path');

    // Reply form
    this.$body.find('[data-behavior~=inline-thread-reply-form]').on('submit', function (e) {
      e.preventDefault();
      var $form = $(this);
      var content = $form.find('textarea').val();
      if (!content.trim()) return;

      var $submitBtn = $form.find('[type=submit]');
      $submitBtn.attr('disabled', 'disabled').text('Sending...');

      $.ajax({
        url: basePath + '/' + thread.id + '/comments',
        method: 'POST',
        dataType: 'script',
        headers: { 'X-CSRF-Token': that.csrfToken },
        data: { comment: { content: content } }
      }).fail(function () {
        $submitBtn.removeAttr('disabled').text('Reply');
      });
    });

    // Resolve button
    this.$body.on('click', '[data-behavior~=resolve-thread]', function () {
      $.ajax({
        url: basePath + '/' + thread.id + '/resolution',
        method: 'POST',
        dataType: 'script',
        headers: { 'X-CSRF-Token': that.csrfToken }
      });
    });

    // Reopen button
    this.$body.on('click', '[data-behavior~=reopen-thread]', function () {
      $.ajax({
        url: basePath + '/' + thread.id + '/resolution',
        method: 'DELETE',
        dataType: 'script',
        headers: { 'X-CSRF-Token': that.csrfToken }
      });
    });
  }

  escapeHtml(str) {
    if (!str) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  formatDate(isoString) {
    if (!isoString) return '';
    var date = new Date(isoString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  }
}
