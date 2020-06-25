(function($, window) {
  function Sidebar($sidebar) {
    this.$sidebar = $sidebar;

    this.$navbar = $sidebar.siblings('[data-behavior~=navbar]');
    this.$navbarBrand = this.$navbar.find('[data-behavior~=navbar-brand]');
    this.$viewContent = $sidebar.siblings('[data-behavior~=view-content]');
    this.storageKey = $sidebar.data('storage-key');

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
      this.$navbarBrand.css('padding-left', 0);
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed')
      this.$viewContent.css({'left': this.$sidebar.css('width'), 'width': 'calc(100vw - ' + this.$sidebar.css('width') + ')'});

      this.changeState(false);
    },
    isSidebarOpen: function() {
      return JSON.parse(localStorage.getItem(this.storageKey))
    },
    open: function() {
      this.$sidebar
        .removeClass('sidebar-collapsed')
        .addClass('sidebar-expanded')
      this.$viewContent.css({'left': this.$sidebar.css('width'), 'width': 'calc(100vw - ' + this.$sidebar.css('width') + ')'});

      var navbarBrandOffset = parseFloat(this.$navbarBrand.css('padding-left').slice(0,-2)) + parseFloat(this.$sidebar.css('width').slice(0,-2) / 1.65);
      this.$navbarBrand.css('padding-left', navbarBrandOffset);
      
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
