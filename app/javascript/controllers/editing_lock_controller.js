import { Controller } from "@hotwired/stimulus"

const HEARTBEAT_INTERVAL = 60000

export default class extends Controller {
  static values = { lockUrl: String, unlockUrl: String }

  connect() {
    this.heartbeatTimer = setInterval(() => this.sendHeartbeat(), HEARTBEAT_INTERVAL)
  }

  disconnect() {
    clearInterval(this.heartbeatTimer)
    this.releaseLock()
  }

  sendHeartbeat() {
    fetch(this.lockUrlValue, {
      method: 'PATCH',
      headers: { 'X-CSRF-Token': this.csrfToken },
    }).then(response => {
      if (response.status === 409) {
        response.json().then(({ user_name: userName }) => {
          clearInterval(this.heartbeatTimer)
          this.showLockTakenWarning(userName)
        })
      }
    })
  }

  showLockTakenWarning(userName) {
    const submitBtn = this.element.nextElementSibling?.querySelector('[type=submit]') ||
                      document.querySelector('form [type=submit]')
    if (submitBtn) submitBtn.disabled = true

    const alert = document.createElement('div')
    alert.className = 'alert alert-danger'
    alert.textContent = `${userName} has taken over this edit. Your changes cannot be saved.`
    this.element.after(alert)
  }

  releaseLock() {
    fetch(this.unlockUrlValue, {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': this.csrfToken },
      keepalive: true,
    })
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content ?? ''
  }
}
