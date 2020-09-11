// jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)

function fileUploadInit() {
  $('[data-behavior~=jquery-upload]').fileupload({
     autoUpload: true,
     dropZone: function(){ return $('[data-behavior~=drop-zone]') },
     pasteZone: function(){ return $('[data-behavior~=drop-zone]') },
     singleFileUploads: true,
     destroy: function(e, data) {
       if (confirm('Are you sure?\n\nProceeding will delete this attachment from the associated node.')) {
         $.blueimp.fileupload.prototype.options.destroy.call(this, e, data);
       }
     }
  }).on('fileuploadadd', function (e, data) { // data.$textarea is added to the input field owned by the editor. So
    // copying, or dragging does not append the attribute.
    var $textarea = (e.originalEvent !== undefined) ? $(e.originalEvent.target) : data.$textarea;

    if ($textarea.is($('[data-behavior~=rich-toolbar]'))) {
      var editorToolbar = $textarea.data('editorToolbar');

      data.$textarea = $textarea;

      $.each(data.files, function (index, file) {
        editorToolbar.insertImagePlaceholder(file.name + ' uploading...', $textarea);
      });
    }
  }).on('fileuploaddone', function (e, data) {
    // Here data.$textarea always exists because we added it in the previous
    // fileuploadadd event, and the data object is shared.
    var $textarea = data.$textarea;

    if ($textarea !== undefined) {
      var editorToolbar = $textarea.data('editorToolbar');

      $.each(data.files, function (index, file) {
        var uploadedFile = data.result[0].url,
            str = '\n!' + file.name + ' uploading...' + '!\n';

        editorToolbar.replaceImagePlaceholder(str, uploadedFile, $textarea);
      });
    };
  });
};

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
