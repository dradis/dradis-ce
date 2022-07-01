// The following object contains Allowed files types set as keys with their corresponding tools as value
const allowedFileTypes = {
  '.nessus': 'Dradis::Plugins::Nessus',
  '.json': 'Dradis::Plugins::Wpscan',
  '.xml': 'Dradis::Plugins::Nmap',
  // we can append more tools here i.e. '.html': 'Dradis::Plugins::Burp::Html'
}

const csrfToken = document.querySelector("meta[name='csrf-token']").content // this will get unique csrf-token from head of html 
const uppyTrigger = "#uppy-dashboard-container" // html element selector on which Uppy will be instantiated
const uppyTriggerElement = document.querySelector(uppyTrigger)

const startUppy = function () {
  // instantiate uppy
  let uppy = new Uppy.Core({
    autoProceed: true,
    restrictions: {
      allowedFileTypes: Object.keys(allowedFileTypes),
    },
    meta: {
      uploader: '', // uploader will contain the tool name and will be set before file upload starts
      authenticity_token: csrfToken // csrf-token will be fetch once and will remain same for all file uploads
    },
    onBeforeUpload: (files) => {
      const updatedFiles = {}
      Object.keys(files).forEach(fileID => {
        // set Tool name in uploader from their file extension
        files[fileID].meta.uploader = allowedFileTypes[`.${files[fileID].extension}`],
          updatedFiles[fileID] = files[fileID]
      })

      return updatedFiles
    },
  }).use(Uppy.Dashboard, { // Uppy.Dashboard will add Dropzone on the target element
    target: uppyTrigger,
    inline: true,
    width: 546,
    showProgressDetails: true,
    height: 330,
    proudlyDisplayPoweredByUppy: false,
  })

  // uncomment line 44 - 47 to test successful upload
  // uppy.use(Uppy.XHRUpload, {
  //   // it will pick the endpoint url where the files will be uploaded and set it in XHRUpload endpoint option
  //   endpoint: uppyTriggerElement.getAttribute('data-endpoint'),
  // })
}

if (uppyTriggerElement) {
  startUppy()
}
