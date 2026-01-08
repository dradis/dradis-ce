(function ($, window) {
  class Sidebar {
    constructor($sidebar) {
      this.$sidebar = $sidebar;
      this.storageKey = $sidebar.data('storage-key');
      this.$toggleLink = $sidebar.find($('[data-behavior~=sidebar-toggle]'));
      this.$resizeHandle = $sidebar.find('[data-behavior~=resize-handle]');
      this.mobileBreakpoint = 992;
      this.widthStorageKey = `${this.storageKey}-width`;
      this.isResizing = false;
      this.isResizable = $sidebar.is('[data-behavior~=resizable]');
      this.minWidth = 224; // must match $sidebar-width in variables.scss
      this.maxWidth = 600;
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

      if (this.isResizable) {
        this.applySavedWidth();

        this.$resizeHandle.on('mousedown', function (e) {
          that.startResize(e);
        });

        $(document).on('mousemove', function (e) {
          that.resize(e);
        });

        $(document).on('mouseup', function () {
          that.stopResize();
        });
      }
    }

    startResize(e) {
      this.isResizing = true;
      this.startX = e.clientX;
      this.startWidth = this.$sidebar.outerWidth();

      e.preventDefault();
      $('body').addClass('user-select-none');
      this.$sidebar.addClass('resizing');
    }

    resize(e) {
      if (!this.isResizing) return;

      const width = this.startWidth + (e.clientX - this.startX);
      const constrainedWidth = Math.min(
        Math.max(width, this.minWidth),
        this.maxWidth,
      );
      this.$sidebar.css('width', `${constrainedWidth}px`);

      // used to update view-content width
      document.documentElement.style.setProperty(
        '--main-sidebar-width',
        `${constrainedWidth}px`,
      );
    }

    stopResize() {
      if (!this.isResizing) return;

      this.isResizing = false;
      $('body').removeClass('user-select-none');
      this.$sidebar.removeClass('resizing');

      const currentWidth = this.$sidebar.outerWidth();
      localStorage.setItem(this.widthStorageKey, currentWidth);
    }

    applySavedWidth() {
      if ($(window).width() < this.mobileBreakpoint) {
        return;
      }

      const savedWidth = localStorage.getItem(this.widthStorageKey);
      const width = savedWidth || this.minWidth;
      this.$sidebar.css('width', `${width}px`);

      // used to update view-content width
      document.documentElement.style.setProperty(
        '--main-sidebar-width',
        `${width}px`,
      );
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
