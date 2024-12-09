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
        that.setViewContentMaxWidth();
      });
    }

    changeState(key, state) {
      localStorage.setItem(key, state);
      Turbolinks.clearCache();
    }

    close() {
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed')
        .attr('data-behavior', 'sidebar');

      this.setViewContentMaxWidth();
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

      this.setViewContentMaxWidth();
      this.changeState(this.storageKey, true);
    }

    setViewContentMaxWidth() {
      const collapsedSidebarsWidth = 10;
      const viewportWidth = $(window).width() - collapsedSidebarsWidth;
      let sidebarsWidth = 0;

      $('[data-behavior~=sidebar]').each(function () {
        sidebarsWidth += $(this).width();
      });

      const limit =
        $(window).width() < this.mobileBreakpoint
          ? viewportWidth
          : viewportWidth - sidebarsWidth;

      $('[data-behavior~=view-content]').css('max-width', limit);
    }

    toggle(openSidebar) {
      openSidebar ? this.open() : this.close();
    }
  }

  window.Sidebar = Sidebar;
})(jQuery, window);
