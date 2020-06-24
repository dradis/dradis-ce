(function($, window) {
  function Sidebar($sidebar) {
    this.$sidebar = $sidebar;

    this.$navbar = $sidebar.siblings('[data-behavior~=navbar]');
    this.$viewContent = $sidebar.siblings('[data-behavior~=view-content]');
    this.storageKey = $sidebar.data('storage-key');

    // Must match $sidebarCollapsed and $sidebarExpanded values from tyluim/variables.scss
    this.collapsedWidth = '6rem';
    this.expandedWidth =  '15.5rem';

    this.init();
  }

  Sidebar.prototype = {
    init: function() {
      this.toggle(this.isSidebarOpen());

      var that = this;

      $('[data-behavior~=sidebar-toggle]').on('click', function(e) {
        if ((that.isSidebarOpen() && $(this).is('[data-behavior~=open-only]')) || ($(e.target).data('behavior') == 'add-node')) return;

        that.toggle(!that.isSidebarOpen());
      });
    },
    changeState: function(state) {
      localStorage.setItem(this.storageKey, state);
      Turbolinks.clearCache();
    },
    close: function() {
      this.$navbar.css('left', '0rem');
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed')
      this.$viewContent.css({'left': this.collapsedWidth, 'width': 'calc(100vw - ' + this.collapsedWidth + ')'});

      this.changeState(false);
    },
    isSidebarOpen: function() {
      return JSON.parse(localStorage.getItem(this.storageKey))
    },
    open: function() {
      this.$navbar.css('left', '9.5rem');
      this.$sidebar
        .removeClass('sidebar-collapsed')
        .addClass('sidebar-expanded')
      this.$viewContent.css({'left': this.expandedWidth, 'width': 'calc(100vw - ' + this.expandedWidth + ')'});

      this.changeState(true);
    },
    toggle: function(openSidebar) {
      if (openSidebar) {
        this.open();
      } else {
        this.close();
      }
    }
  }

  window.Sidebar = Sidebar;
})(jQuery, window);
