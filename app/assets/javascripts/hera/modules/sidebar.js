(function ($, window) {
  class Sidebar {
    constructor($sidebar) {
      this.$sidebar = $sidebar;
      this.storageKey = $sidebar.data('storage-key');
      this.$toggleLink = $sidebar.find($('[data-behavior~=sidebar-toggle]'));

      this.init();
    }

    init() {
      this.toggle(this.isSidebarOpen());

      const that = this;

      this.$toggleLink.on('click', function () {
        that.toggle(!that.isSidebarOpen());
      });
    }

    changeState(key, state) {
      localStorage.setItem(key, state);
      Turbolinks.clearCache();
    }

    close() {
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed');

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
        .addClass('sidebar-expanded');

      this.changeState(this.storageKey, true);
    }
    toggle(openSidebar) {
      openSidebar ? this.open() : this.close();
    }
  }

  window.Sidebar = Sidebar;
})(jQuery, window);
