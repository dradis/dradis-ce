// jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)

function fileUploadInit($element = $('[data-behavior~=jquery-upload]')) { 

  $element.each(function() {

    if ($(this).is($('[data-behavior~=editor-field'))) {

      // Config for Editor Fields
      var actionPath = $(this).parents().find('#fileupload').attr('action');

      $(this).fileupload({
        autoUpload: true,
        dropZone: $(this).find('[data-behavior~=drop-zone]'),
        pasteZone: null, // Disable uploading files on paste in the textarea (this prevents a double upload since the attachment box pasteZone is the entire document)
        singleFileUploads: true,
        url: actionPath,
      }).on('fileuploadadd', function (e, data) {

        // inject placeholder into textarea for each dragged in file
        $(this).find('[data-behavior~=rich-toolbar').focus()
        $.each(data.files, function (index, file) {
          document.execCommand('insertText', false, '! ' + file.name + ' uploading... !\n');
        })
      }).on('fileuploaddone', function (e, data) {

        var uploadedFile = data.result[0].url
        var $textarea = $(this).find('[data-behavior~=rich-toolbar')
        
        $.each(data.files, function (index, file) {

          // remove placeholder from textarea for each file once it's uploaded
          $textarea.focus().val($textarea.val().replace(/\!.*\!\n/, ''));

          // inject syntax into textarea to automatically display uploaded image
          document.execCommand('insertText', false, '!' + uploadedFile + '!\n');
        })
      })
    } 
    else {

      // Config for attachments-box
      $('[data-behavior~=jquery-upload]').fileupload({
        autoUpload: true,
        dropZone: $(this).find('[data-behavior~=drop-zone]'),
        destroy: function(e, data) {
          if (confirm('Are you sure?\n\nProceeding will delete this attachment from the associated node.')) {
            $.blueimp.fileupload.prototype.options.destroy.call(this, e, data);
          }
        },
        paste: function(e, data) {
          $.each(data.files, function(index, file) {
            var filename, newFile;
            filename = prompt('Please provide a filename for the pasted image', 'screenshot-XX.png') || 'unnamed.png';
            newFile = new File([file], filename, {
              type: file.type
            });
            data.files[index] = newFile;
          });
        }
      })
    }
  });
}

document.addEventListener("turbolinks:load", function() {
  // Bind fileUpload on page load.
  fileUploadInit();
});

// Un-bind fileUpload on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  $('[data-behavior~=jquery-upload]').each(function() {
    $(this).fileupload('destroy');
  });
});
  