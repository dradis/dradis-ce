import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['comment', 'count', 'empty']

  // The feed is cached for every user, so own comments are marked here.
  commentTargetConnected(comment) {
    const currentUserId = document.querySelector('meta[name=current-user-id]')?.content
    if (comment.dataset.authorId === currentUserId) {
      comment.querySelector('[data-behavior~=comment-actions]')?.classList.add('current_user')
    }

    comment.querySelectorAll('[data-behavior~=content-textile]').forEach((content) => new QuoteSelector(content))
    this.refresh()
  }

  commentTargetDisconnected() {
    this.refresh()
  }

  // Count the comments on the page, so the ones Gateway adds are included.
  refresh() {
    const count = this.commentTargets.length

    this.countTarget.textContent = count
    this.emptyTarget.classList.toggle('d-none', count > 0)
  }
}
