(function ($, window) {
  class Sidebar {
    constructor($sidebar) {
      this.$sidebar = $sidebar;
      this.storageKey = $sidebar.data('storage-key');
      this.$toggleLink = $sidebar.find($('[data-behavior~=sidebar-toggle]'));
      this.mobileBreakpoint = 992;

      this.init();
    }

    init() {
      this.toggle(this.isSidebarOpen());

      const that = this;

      this.$toggleLink.on('click', function () {
        that.toggle(!that.isSidebarOpen());
      });

      $(window).on('resize', function () {
        if ($(window).width() < that.mobileBreakpoint) {
          that.close();
        }
      });

      if ($('[data-behavior~=local-auto-save]').length) {
        that.close(true);
      }
    }

    changeState(key, state) {
      localStorage.setItem(key, state);
      Turbo.cache.clear();
    }

    close(skipChangeState = false) {
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed')
        .attr('data-behavior', 'sidebar');

      if (skipChangeState) return;

      this.changeState(this.storageKey, false);
    }

    isSidebarOpen() {
      if (JSON.parse(localStorage.getItem(this.storageKey)) === null) {
        return true;
      } else {
        return JSON.parse(localStorage.getItem(this.storageKey));
      }
    }

    open() {
      this.$sidebar
        .removeClass('sidebar-collapsed')
        .addClass('sidebar-expanded')
        .attr('data-behavior', 'sidebar sidebar-expanded');

      this.changeState(this.storageKey, true);
    }

    toggle(openSidebar) {
      openSidebar ? this.open() : this.close();
    }
  }

  window.Sidebar = Sidebar;
})(jQuery, window);
