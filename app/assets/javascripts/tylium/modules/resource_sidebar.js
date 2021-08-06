document.addEventListener('turbolinks:load', function() {

  if ($('[data-behavior~=resource-sidebar]').length) {
    const $resourceSidebar = $('[data-behavior~=resource-sidebar]'),
          $resourceSidebarToggle = $('[data-behavior~=resource-sidebar-toggle]'),
          localStorageKey = 'project.ce.resource-sidebar-collapsed',
          savedState = localStorage.getItem(localStorageKey);

    function toggleResourceSidebar() {
      $resourceSidebar.toggleClass('collapsed');
      $resourceSidebarToggle.find('i').toggleClass('fa-chevron-right fa-chevron-left');
      localStorage.setItem(localStorageKey, $resourceSidebar.hasClass('collapsed'));
      Turbolinks.clearCache();
    }

    if (savedState == 'true') {
      toggleResourceSidebar();
    }

    $resourceSidebarToggle.on('click', function() {
      toggleResourceSidebar();
    });
  };
});