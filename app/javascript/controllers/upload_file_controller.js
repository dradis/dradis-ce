import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filename", "toolSelect", "progressContainer", "progressBar", "progressPercent", "statusLabel", "consoleButton", "consoleModal"]

  connect() {
    this._file = this.element._uploadFile
    if (!this._file) return

    this.filenameTarget.textContent = this._file.name
    this.detectTool()
  }

  toolChanged() {
    this.dispatch('changed', { bubbles: true })
  }

  remove() {
    const parent = this.element.parentElement
    this.element.remove()
    if (parent) {
      parent.dispatchEvent(new CustomEvent('upload-file:removed', { bubbles: true }))
    }
  }

  consoleComplete() {
    this.statusLabelTarget.textContent = 'Done!'
  }

  openConsole() {
    new window.bootstrap.Modal(this.consoleModalTarget).show()
  }

  async detectTool() {
    const sample = await this.readSample(this._file)
    const { detect } = await import('upload_detector_registry')
    const toolName = detect(sample, this._file.name)

    if (toolName) {
      this.toolSelectTarget.value = toolName
    }

    this.dispatch('changed', { bubbles: true })
  }

  async upload(uploadUrl, parseUrl, state) {
    return new Promise((resolve, reject) => {
      const formData = new FormData()
      formData.append('file', this._file)
      formData.append('uploader', this.toolSelectTarget.value)
      formData.append('state', state)

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const xhr = new XMLHttpRequest()

      xhr.upload.onprogress = (event) => {
        if (!event.lengthComputable) return
        const percent = Math.round((event.loaded / event.total) * 100)
        this.progressBarTarget.style.width = `${percent}%`
        this.progressPercentTarget.textContent = `${percent}%`
      }

      xhr.onload = async () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          const data = JSON.parse(xhr.responseText)

          this.consoleModalTarget.dataset.uploadConsoleItemIdValue = data.item_id

          const parseData = new FormData()
          parseData.append('file', data.attachment)
          parseData.append('item_id', data.item_id)
          parseData.append('uploader', this.toolSelectTarget.value)
          parseData.append('state', state)

          await fetch(parseUrl, {
            method: 'POST',
            headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {},
            body: parseData
          })

          this.statusLabelTarget.textContent = 'Processing...'
          this.consoleButtonTarget.classList.remove('d-none')
          resolve()
        } else {
          this.statusLabelTarget.textContent = 'Upload failed'
          reject(new Error(`Upload failed: ${xhr.status}`))
        }
      }

      xhr.onerror = () => {
        this.statusLabelTarget.textContent = 'Network error'
        reject(new Error('Upload network error'))
      }

      xhr.open('POST', uploadUrl)
      if (csrfToken) xhr.setRequestHeader('X-CSRF-Token', csrfToken)
      xhr.setRequestHeader('Accept', 'application/json')
      xhr.send(formData)

      this.progressContainerTarget.classList.remove('d-none')
      this.statusLabelTarget.textContent = 'Uploading...'
    })
  }

  readSample(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = (e) => resolve(e.target.result)
      reader.onerror = reject
      reader.readAsText(file.slice(0, 4096))
    })
  }
}
