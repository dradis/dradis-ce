// jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)

// Bind fileUpload on page load.
document.addEventListener("turbolinks:load", function() {
  if ($('[data-behavior~=jquery-upload]').length) {
    $('[data-behavior~=jquery-upload]').fileupload({
      dropZone: $('#drop-zone'),
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
    });
  }
});

// Un-bind fileUpload on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  if ($('[data-behavior~=jquery-upload]').length) {
    $('[data-behavior~=jquery-upload]').fileupload('destroy');
  }
});
  