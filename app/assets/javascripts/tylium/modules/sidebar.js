(function ($, window) {
  function Sidebar($sidebar) {
    this.$sidebar = $sidebar;
    this.minBreakpoint = 992;
    this.$navbarBrand = $sidebar
      .siblings('[data-behavior~=navbar]')
      .find('[data-behavior~=navbar-brand]');
    this.storageKey = $sidebar.data('storage-key');
    this.$toggleLink = $sidebar.find($('[data-behavior~=sidebar-toggle]'));
    this.$viewContent = $sidebar.siblings('[data-behavior~=view-content]');

    this.init();
  }

  Sidebar.prototype = {
    init: function () {
      this.toggle(this.isSidebarOpen());

      var that = this;

      this.$toggleLink.on('click', function (e) {
        if ($(this).is('[data-behavior~=nodes-tree]')) {
          if (window.innerWidth < that.minBreakpoint) {
            $(this).attr('data-behavior', 'nodes-tree sidebar-toggle');
          } else {
            $(this).attr(
              'data-behavior',
              'nodes-tree sidebar-toggle open-only'
            );
          }
        }

        if (
          !(that.isSidebarOpen() && $(this).is('[data-behavior~=open-only]'))
        ) {
          that.toggle(!that.isSidebarOpen());
        }
      });

      if (window.innerWidth < that.minBreakpoint) {
        $('[data-behavior~=sidebar-node-link]').on('click', function () {
          that.close();
        });
      }

      $(window).on('resize', function () {
        if (window.innerWidth < that.minBreakpoint) {
          that.$navbarBrand.css('padding-left', 0);
        }

        that.isSidebarOpen() ? that.open() : that.close();
      });
    },
    changeState: function (state) {
      localStorage.setItem(this.storageKey, state);
      Turbolinks.clearCache();
    },
    close: function () {
      this.$sidebar
        .removeClass('sidebar-expanded')
        .addClass('sidebar-collapsed');

      if (this.$sidebar.is($('[data-behavior~=main-sidebar]'))) {
        this.$navbarBrand.css('padding-left', 0);
        this.$viewContent.css({
          left: this.$sidebar.css('width'),
          width: 'calc(100vw - ' + this.$sidebar.css('width') + ')',
        });
      }

      this.changeState(false);
    },
    isSidebarOpen: function () {
      if (JSON.parse(localStorage.getItem(this.storageKey)) === null) {
        return true;
      } else {
        return JSON.parse(localStorage.getItem(this.storageKey));
      }
    },
    open: function () {
      this.$sidebar
        .removeClass('sidebar-collapsed')
        .addClass('sidebar-expanded');

      if (this.$sidebar.is($('[data-behavior~=main-sidebar]'))) {
        this.$viewContent.css({
          left: this.$sidebar.css('width'),
          width: 'calc(100vw - ' + this.$sidebar.css('width') + ')',
        });

        if (window.innerWidth > this.minBreakpoint) {
          var navbarBrandOffset = parseFloat(
            this.$sidebar.css('width').slice(0, -2) / 1.65
          );
          this.$navbarBrand.css('padding-left', navbarBrandOffset);
        }
      }

      this.changeState(true);
    },
    toggle: function (openSidebar) {
      if (openSidebar) {
        this.open();
      } else {
        this.close();
      }
    },
  };

  window.Sidebar = Sidebar;
})(jQuery, window);
