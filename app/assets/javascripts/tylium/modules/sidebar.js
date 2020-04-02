(function($, window) {
  function Sidebar($sidebar) {
    this.$sidebar = $sidebar;

    this.$navbar = $sidebar.siblings('[data-behavior~=navbar]');
    this.$viewContent = $sidebar.siblings('[data-behavior~=view-content]');
    this.storageKey = $sidebar.data('storage-key');

    this.init();
  }

  Sidebar.prototype = {
    init: function() {
      this.toggle(this.isSidebarOpen(), 'no-animation');

      var that = this;
      $('[data-behavior~=sidebar-toggle]').on('click', function() {
        if (that.isSidebarOpen() && $(this).is('[data-behavior~=open-only]')) return;

        that.toggle(!that.isSidebarOpen(), 'animate');
      });
    },
    changeState: function(state) {
      localStorage.setItem(this.storageKey, state);
      Turbolinks.clearCache();
    },
    close: function(animationClass) {
      this.$navbar.css('left', '0px');
      this.$sidebar
        .removeClass('sidebar-expanded no-animation animate')
        .addClass('sidebar-collapsed ' + animationClass)
      this.$viewContent.css({'left': '43px', 'width': 'calc(100vw - 43px)'});

      this.changeState(false);
    },
    isSidebarOpen: function() {
      return JSON.parse(localStorage.getItem(this.storageKey))
    },
    open: function(animationClass) {
      this.$navbar.css('left', '207px');
      this.$sidebar
        .removeClass('sidebar-collapsed no-animation animate')
        .addClass('sidebar-expanded ' + animationClass)
      this.$viewContent.css({'left': '250px', 'width': 'calc(100vw - 250px)'});

      this.changeState(true);
    },
    toggle: function(openSidebar, animationClass) {
      if (openSidebar) {
        this.open(animationClass);
      } else {
        this.close(animationClass);
      }
    }
  }

  window.Sidebar = Sidebar;
})(jQuery, window);
