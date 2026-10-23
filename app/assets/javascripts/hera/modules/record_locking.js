class RecordLocking {
  constructor(link) {
    this.link = link;
    this.path = link.dataset.recordLockingPath;

    this.behaviors();
  }

  behaviors() {
    this.link.addEventListener('click', () => this.release());
  }

  // Uses keepalive so the request still completes even though the click
  // also triggers a full-page navigation away from the current document.
  release() {
    if (!this.path) { return; }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch(this.path, {
      method: 'DELETE',
      keepalive: true,
      headers: { 'X-CSRF-Token': csrfToken },
    });
  }
}
