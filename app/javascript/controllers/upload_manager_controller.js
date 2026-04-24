import { Controller } from "@hotwired/stimulus"

const PROJECTS_UPLOADERS = [
  'Dradis::Plugins::Projects::Upload::Package',
  'Dradis::Plugins::Projects::Upload::Template',
]

export default class extends Controller {
  static targets = ["dropZone", "fileInput", "stagingArea", "rowTemplate", "uploadButton", "stateSelect"]
  static values = { uploadUrl: String, parseUrl: String }

  connect() {
    this.rowIndex = 0
    this.updateUploadButton()
  }

  openFilePicker() {
    this.fileInputTarget.click()
  }

  filesSelected() {
    this.addFiles(Array.from(this.fileInputTarget.files))
    this.fileInputTarget.value = ''
  }

  drop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('upload-drop-zone--active')
    this.addFiles(Array.from(event.dataTransfer.files))
  }

  dragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add('upload-drop-zone--active')
  }

  dragLeave() {
    this.dropZoneTarget.classList.remove('upload-drop-zone--active')
  }

  addFiles(files) {
    files.forEach(file => this.addRow(file))
  }

  addRow(file) {
    const fragment = this.rowTemplateTarget.content.cloneNode(true)
    const rowEl = fragment.firstElementChild
    rowEl._uploadFile = file
    this.stagingAreaTarget.appendChild(rowEl)
  }

  rowChanged() {
    this.updateUploadButton()
    this.updateStateSelect()
  }

  rowRemoved() {
    this.updateUploadButton()
    this.updateStateSelect()
  }

  async upload() {
    const rows = this.stagingAreaTarget.querySelectorAll('[data-controller~="upload-file"]')
    const controllers = Array.from(rows).map(el =>
      this.application.getControllerForElementAndIdentifier(el, 'upload-file')
    )

    this.uploadButtonTarget.disabled = true

    await Promise.allSettled(
      controllers.map(c => c.upload(this.uploadUrlValue, this.parseUrlValue, this.stateSelectTarget.value))
    )
  }

  updateUploadButton() {
    const rows = Array.from(this.stagingAreaTarget.querySelectorAll('[data-controller~="upload-file"]'))

    if (rows.length === 0) {
      this.uploadButtonTarget.disabled = true
      return
    }

    const allReady = rows.every(row => {
      const sel = row.querySelector('[data-upload-file-target="toolSelect"]')
      return sel && sel.value !== ''
    })
    this.uploadButtonTarget.disabled = !allReady
  }

  updateStateSelect() {
    const rows = Array.from(this.stagingAreaTarget.querySelectorAll('[data-controller~="upload-file"]'))
    const selectedOption = this.stateSelectTarget.options[this.stateSelectTarget.selectedIndex]

    const hasProjects = rows.some(row => {
      const sel = row.querySelector('[data-upload-file-target="toolSelect"]')
      return sel && PROJECTS_UPLOADERS.includes(sel.value)
    })

    if (hasProjects) {
      this.stateSelectTarget.disabled = true
      this.stateSelectTarget.classList.add('disabled')
      selectedOption.text = 'Imported from file'
    } else {
      this.stateSelectTarget.disabled = false
      this.stateSelectTarget.classList.remove('disabled')
      const state = selectedOption.value.replaceAll('_', ' ')
      selectedOption.text = state.charAt(0).toUpperCase() + state.slice(1)
    }
  }
}
