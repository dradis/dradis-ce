document.addEventListener('turbolinks:load', function () {
  // Activate jQuery.breadCrumbs
  $('.breadcrumb').breadcrumbs({
    tree: $('.main-sidebar .tree-navigation'),
  });

  // Activate jQuery.treeNav
  $('.tree-navigation').treeNav();

  // Activate jQuery.treeModal
  $('.modal-node-selection-form').treeModal();

  // Focus first input on modal window display.
  $('.modal').on('shown.bs.modal', function () {
    $(this).find('input:text:visible:first').focus();
  });

  // If project id is changed in project path
  if (!/^\/projects\/1(\/|$)/.test(window.location.pathname)) {
    $('[data-behavior~=project-teaser]').removeClass('d-none');
  }

  if ($('#activities-poller').length) {
    if (!ActivitiesPoller.initialized) {
      ActivitiesPoller.init($('#activities-poller'));
      ActivitiesPoller.poll();
    }
  }

  // Disable form buttons after submitting them.
  $('form').submit(function (ev) {
    if (
      !$('input[type=submit]', this).is('[data-behavior~=skip-auto-disable]')
    ) {
      $('input[type=submit]', this)
        .attr('disabled', 'disabled')
        .val('Processing...');
    }
  });

  // Toggle sidebar menu
  $('[data-behavior~=main-sidebar]').each(function () {
    new Sidebar($(this));
  });

  // Disable turbolinks for on-page anchor links (prevents page from jumping to top and allows smooth-scrolling)
  if ($('a[href^="#"]').length) {
    $('a[href^="#"]').each(function () {
      if (!$(this).data('turbolinks')) {
        $(this).attr('data-turbolinks', 'false');
      }
    });
  }

  // Smooth Scrolling - scroll to element on page load if hash present in current browser url
  if (window.location.hash) {
    const target = window.location.hash;
    $(target)[0].scrollIntoView({ behavior: 'smooth' });
  }
});
