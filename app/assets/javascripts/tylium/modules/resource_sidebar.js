document.addEventListener('turbolinks:load', function() {
  const $resourceSidebar = $('[data-behavior~=resource-sidebar]'),
        $resourceSidebarToggle = $('[data-behavior~=resource-sidebar-toggle]'),
        localStorageKey = 'project.ce.resource-sidebar-collapsed',
        savedState = localStorage.getItem(localStorageKey);
  
  function toggleResourceSidebar() {
    $resourceSidebar.toggleClass('collapsed');
    $resourceSidebarToggle.find('i').toggleClass('fa-chevron-right fa-chevron-left');
    localStorage.setItem(localStorageKey, $resourceSidebar.hasClass('collapsed'));
  }
  
  if (savedState == 'true') {
    toggleResourceSidebar();
  }

  $resourceSidebarToggle.on('click', function() {      
    toggleResourceSidebar();
  });
});
