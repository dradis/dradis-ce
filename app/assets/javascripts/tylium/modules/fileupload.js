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
  }).on('fileuploadadd', function (e, data) {
    var $textarea = (e.originalEvent !== undefined) ? $(e.originalEvent.target) : data.$textarea;

    if ($textarea.is($('[data-behavior~=rich-toolbar]'))) {
      var editorToolbar = $textarea.data('editorToolbar');

      data.$textarea = $textarea;

      $.each(data.files, function (index, file) {
        affix = editorToolbar.affixes['image'];
        str = affix.withSelection(file.name + ' uploading...');
        editorToolbar.replace(str, $textarea);

        var position = $textarea.val().indexOf(str) + str.length;
        $textarea.focus();
        $textarea[0].setSelectionRange(position, position);
      });
    }
  }).on('fileuploaddone', function (e, data) {
    var $textarea = data.$textarea;

    if ($textarea !== undefined) {
      var editorToolbar = $textarea.data('editorToolbar');

      $.each(data.files, function (index, file) {
        var uploadedFile = data.result[0].url,
            str = '\n!' + file.name + ' uploading...' + '!\n';

        // remove placeholder from textarea for each file once it's uploaded
        //$textarea.focus().val($textarea.val().replace(str, ''));

        // inject syntax into textarea to automatically display uploaded image
        affix = editorToolbar.affixes['image'].withSelection(uploadedFile);
        $textarea.val($textarea.val().replace(str, affix, $textarea));

        var position = $textarea.val().indexOf(affix) + affix.length;
        $textarea.focus();
        $textarea[0].setSelectionRange(position, position);
      })

      $textarea.trigger('textchange');
    }
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
