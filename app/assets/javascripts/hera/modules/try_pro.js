document.addEventListener('turbo:load', function () {
  $('body').on('click', '.js-try-pro', function () {
    var $this = $(this);
    var term = $this.data('term');
    var $modal = $('#try-pro');
    var $iframe = $('#try-pro iframe');
    var url = $iframe.data('url');

    if ($this.data('url')) {
      url = $this.data('url');
      var title;
      switch (term) {
        case 'boards':
          title =
            '<span>[Dradis Pro feature]</span> Advanced boards and task assignment';
          break;
        case 'contact-support':
          title = '<span>[Dradis Pro feature]</span> Dedicated Support team';
          break;
        case 'issuelib':
          title =
            '<span>[Dradis Pro feature]</span> Integrated library of vulnerability descriptions';
          break;
        case 'gateway':
          title =
            '<span>[Dradis Pro feature]</span> A Dynamic and Interactive Assessment Results Portal';
          break;
        case 'projects':
          title =
            '<span>[Dradis Pro feature]</span> Work with multiple projects';
          break;
        case 'remediation':
          title =
            '<span>[Dradis Pro feature]</span> Integrated remediation tracker';
          break;
        case 'word-reports':
          title = '<span>[Dradis Pro feature]</span> Custom Word reports';
          break;
        case 'excel-reports':
          title = '<span>[Dradis Pro feature]</span> Custom Excel reports';
          break;
        case 'node-boards':
          title = '<span>[Dradis Pro feature]</span> Node-level methodologies';
          break;
        case 'training-course':
          title = 'Dradis Training Course';
          break;
        case 'try-pro':
          title = 'Upgrade to Dradis Pro';
          break;
        default:
          title = 'Dradis Pro feature';
      }
      $modal.find('[data-behavior~=modal-title]').html(title);
    } else {
      $modal
        .find('[data-behavior~=modal-title]')
        .text('Dradis Framework editions');
    }

    url +=
      '?utm_source=ce&utm_medium=app&utm_campaign=try-pro&utm_term=' + term;
    $iframe.attr('src', url);
    new bootstrap.Modal('#try-pro').show();
  });
});
