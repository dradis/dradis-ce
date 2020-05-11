// jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)

function fileUploadInit($element = $('[data-behavior~=jquery-upload]')) { 

  $element.each(function() {

    $(this).fileupload({
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
    }).on('fileuploadadd', function (e, data) {

      // Auto-upload if file is dropped on editor fields
      if ($(this).is('[data-behavior~=editor-field]')) {

        // Use path from attachments box in sidebar
        var attachmentsPath = $(this).parents().find('#fileupload').attr('action');
        
        $(this).fileupload('option', { 
          autoUpload: true,
          url: attachmentsPath,
          singleFileUploads: true
        });
      }
    }).on('fileuploadstart', function (e, data) {

      // inject syntax to editor field textarea
      if ($(this).is('[data-behavior~=editor-field]')) {
        $(this).find('[data-behavior~=rich-toolbar').focus()

        document.execCommand('insertText', false, '! File upload in progress... !\n');
      }
    }).on('fileuploaddone', function (e, data) {

      // inject syntax to editor field textarea
      if ($(this).is('[data-behavior~=editor-field]')) {
        var uploadedFile = data.result[0].url
        
        $(this).find('[data-behavior~=rich-toolbar').focus().val($(this).val().replace(/! File upload in progress... !/i, ''));
        document.execCommand('insertText', false, '!' + uploadedFile + '!\n');
      }
    })
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
  