const allowedFileTypes = {
  '.nessus': 'Dradis::Plugins::Nessus',
  '.json': 'Dradis::Plugins::Wpscan',
  '.xml': 'Dradis::Plugins::Nmap',
}

const csrfToken = document.querySelector("meta[name='csrf-token']").content
const uppyTrigger = "#uppy-dashboard-container"
const uppyTriggerElement = document.querySelector(uppyTrigger)

const startUppy = function () {
  let uppy = new Uppy.Core({
    autoProceed: true,
    restrictions: {
      allowedFileTypes: Object.keys(allowedFileTypes),
    },
    meta: {
      uploader: '',
      authenticity_token: csrfToken
    },
    onBeforeUpload: (files) => {
      const updatedFiles = {}
      Object.keys(files).forEach(fileID => {
        files[fileID].meta.uploader = allowedFileTypes[`.${files[fileID].extension}`],
          updatedFiles[fileID] = files[fileID]
      })

      return updatedFiles
    },
  }).use(Uppy.Dashboard, {
    target: uppyTrigger,
    inline: true,
    width: 546,
    showProgressDetails: true,
    height: 330,
    proudlyDisplayPoweredByUppy: false,
  })

  // uncomment line 40, 41 and 42 to test successful upload
  // uppy.use(Uppy.XHRUpload, {
  //   endpoint: uppyTriggerElement.getAttribute('data-endpoint'),
  // })
}

if (uppyTriggerElement) {
  startUppy()
}
