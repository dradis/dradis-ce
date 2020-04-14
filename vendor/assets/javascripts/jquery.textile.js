// Textile editor plugin with Write/Preview/Fullscreen functionality
//
// References:
//   jQuery boilerplate - http://jqueryboilerplate.com/
//   Inspired in redactor.js - http://redactorjs.com/

// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, undefined ) {

  // undefined is used here as the undefined global variable in ECMAScript 3 is
  // mutable (ie. it can be changed by someone else). undefined isn't really being
  // passed in so we can ensure the value of it is truly undefined. In ES5, undefined
  // can no longer be modified.

  // window and document are passed through as local variables rather than globals
  // as this (slightly) quickens the resolution process and can be more efficiently
  // minified (especially when both are regularly referenced in your plugin).

  // Create the defaults once
  var pluginName = 'textile',
      document = window.document,
      defaults = {
        // Start fullscreen?
        fullscreen: false,
        // Add a resizer bar at the bottom of the editor
        resize: true,
        // HTML templates
        tpl: {
          inline: '<div class="textile-form h-100 col-6"></div>',
          wrap: '<div class="textile-wrap"><ul class="textile-toolbar"></ul><div class="textile-inner row"></div></div>',
          preview: '<div class="col-6"><div class="textile-preview loading-indicator">Loading...</div></div>',
          help: '<div class="textile-help col-12 loading-indicator">Loading...</div>'
        }
      };

  // The actual plugin constructor
  function Plugin( element, options ) {
    this.$element = $(element);

    // jQuery has an extend method which merges the contents of two or
    // more objects, storing the result in the first object. The first object
    // is generally empty as we don't want to alter the default options for
    // future instances of the plugin
    this.options = $.extend( {}, defaults, options) ;

    this._defaults = defaults;
    this._name = pluginName;

    this.init();
  }

  Plugin.prototype = {
    init: function () {
      // Place initialization logic here
      // You already have access to the DOM element and the options via the instance,
      // e.g., this.element and this.options
      this._buildContainer();

      this._previousContent = this.$element.val();
      this._previewRendered = false;
      this._helpRendered = false;
      this._doneTypingInterval = 500;
    },
    _buildContainer: function() {
      // Add wrapper div with toolbar and inner container (see defaults.tpl)

      // container
      this.options.$wrap = $(this.options.tpl.wrap);
      this.$element.parent().append( this.options.$wrap );

      // move textarea to container
      this.$source = this.$element.wrap('<div class="col-6"></div>').parent();
      $('.textile-inner', this.options.$wrap).append(this.$source);
      this.$source.hide();

      // add Form
      this.options.$inline = $(this.options.tpl.inline);
      $('.textile-inner', this.options.$wrap).append(this.options.$inline);
      this._loadInline(this.$element.val(), this.$element.data('allow-dropdown'));

      // add Preview to container and load
      this.options.$preview = $(this.options.tpl.preview);
      $('.textile-inner', this.options.$wrap).append(this.options.$preview);
      this.options.$preview.children(':first').addClass('textile-preview');
      this._loadPreview({ text: this.$element.val() });

      // add Help to container and hide
      this.options.$help = $(this.options.tpl.help);
      $('.textile-inner', this.options.$wrap).append(this.options.$help);
      this.options.$help.hide();

      // toolbar
      this._buildToolbar();

      // Event bindings
      this._bindBehaviors();
    },
    _bindBehaviors: function() {
      // Sync preview
      // on keyup, start the countdown
      this.$element.on('textchange load-preview', function() {
        clearTimeout(this._typingTimer);
        this._typingTimer = setTimeout(this._onKeyPressPreview.bind(this, 'text'), this._doneTypingInterval);
      }.bind(this));

      // When auto-save populates data into source view refresh the form
      this.$element.on('load-preview', function() {
        this._loadInline(this.$element.val());
      }.bind(this));

      // Bind all form element actions within container
      this.bindFieldGroup(this.options.$inline);
    },
    bindFieldGroup: function($parent) {
      var that = this;

      $parent.find('[data-behavior~=delete-field]').click(function(){
        $(this).closest('[data-behavior~=textile-form-field]').remove();
        that._timedPreview.bind(that)();
      });

      $parent.find('[data-behavior~=edit-field]').click(function(){
        $parent.find($(this).data('edit-field')).focus();
      });

      // Handler for triggering the preview on keyboard input
      $parent.find('[data-behavior~=preview-enabled]').on('textchange load-preview', this._timedPreview.bind(this));
    },
    _timedPreview: function(view) {
      clearTimeout(this._typingTimer);
      this._typingTimer = setTimeout(function() {
        this._onKeyPressPreview.bind(this, view)

        // Piggy back this event for the purpose of updating the source view, which will trigger auto-save
        // This will be updated/refactored when auto-save is re-worked. Currently it will cause an extra request per edit.
        this._loadSource();
        this.$element.trigger('textchange');
      }.bind(this), this._doneTypingInterval);
    },
    _buildToolbar: function() {
      var button;

      // Form
      button = $('<a class="btn-form active" href="javascript:void(null);"><span>Inline</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnInline(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li>').append(button) );

      // Source
      button = $('<a class="btn-write" href="javascript:void(null);"><span>Source</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnSource(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li>').append(button) );

      // Full screen
      // button = $('<a class="btn btn-fullscreen" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button = $('<a class="btn-fullscreen fa fa-expand" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnFullScreen(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );

      // Help
      button = $('<a class="btn-help fa fa-question" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnHelp(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );
    },
    _buildResizer: function() {
      if (this.options.resize === false) return false;

    },
    // Ajax form
    _loadInline: function(data, allowDropdown) {
      $.post({
        url: this.$element.data('form-url') + '.js',
        data: {source: data, allow_dropdown: allowDropdown},
        beforeSend: function(){
          this.options.$inline.addClass('loading-indicator').text('Loading...');
        }.bind(this)
      });
    },
    // Ajax help
    _loadHelp: function() {
      var that = this;
      $.get( this.$element.data('help-url'), function(result){
        that.options.$help.removeClass('loading-indicator')
          .html(result);
        this._helpRendered = true;
      });
    },
    // Ajax preview
    _loadPreview: function(data) {
      this._previousContent = this.$element.val();

      $.post(this.$element.data('preview-url'),
        data,
        function(result) {
          this.options.$preview.removeClass('loading-indicator')
            .html(result);
          this.options.$preview.children(':first').addClass('textile-preview');
          this._previewRendered = true;
        }.bind(this)
      );
    },
    // Ajax write
    _loadSource: function() {
      $.post(
        this.$element.data('source-url'),
        { form: this._serializedFormData() },
        function(result){
          this.$element.val(result);
        }.bind(this)
      );
    },
    _onKeyPressPreview: function(type) {
      if (type == 'inline') {
        this._loadPreview({ inline: this._serializedFormData() });
      }
      else if (type == 'text') {
        // If the text hasn't changed, do nothing.
        if (this._previousContent == this.$element.val()) {
          if (!this._previewRendered) {
            this._loadPreview({ text: this.$element.val() });
          }
        } else {
          this._loadPreview({ text: this.$element.val() });
        }
      }
    },
    _onBtnInline: function() {
      // Activate toolbar button
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-form', scope).addClass('active');

      $('.textile-form').empty();

      this._loadInline(this.$element.val(), false);

      // Show Form pane
      this.options.$help.hide();
      this.$source.hide();
      this.options.$preview.show();
      this.options.$inline.show();
    },
    _onBtnFullScreen: function() {
      $btnFS = $('.btn-fullscreen', this.options.$wrap);

      if (this.options.fullscreen === false ) {
        this.options.fullscreen = true;

        this.options.height = this.$element.css('height');
        this.options.width  = this.options.$wrap.css('width');

        this.options.tmpspan = $('<span></span>');
        this.options.$wrap.addClass('textile-fullscreen').after(this.options.tmpspan);

        $(document.body).prepend(this.options.$wrap).css('overflow', 'hidden');

        // fit to window
        this._onFullScreenResize();

        // refit whenever the window resizes
        $(window).resize($.proxy(this._onFullScreenResize, this));

        // update button icon
        $btnFS.removeClass('fa-expand').addClass('fa-compress');

        // back to top for good measure
        $(document).scrollTop(0,0);
      }
      else
      {
        this.options.fullscreen = false;

        // stop listening to resize events
        $(window).unbind('resize', $.proxy(this._onFullScreenResize, this));
        $(document.body).css('overflow', 'visible');

        this.options.$wrap.removeClass('textile-fullscreen');
        this.options.$wrap.css('width', 'auto');
        this.options.tmpspan.after(this.options.$wrap).remove();

        this.options.$preview.css('height', '100%');
        this.$element.css('height', this.options.height);

        // update button icon
        $btnFS.removeClass('fa-compress').addClass('fa-expand');
      }
    },
    _onBtnHelp: function() {
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-help', scope).addClass('active');

      // Show Help pane
      this.$source.hide();
      this.options.$inline.hide();
      this.options.$preview.hide();
      this.options.$help.show();

      if (!this._helpRendered) {
        this._loadHelp();
      }
    },
    // Toolbar button handlers
    _onBtnSource: function() {
      // Activate toolbar button
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-write', scope).addClass('active');

      // Clear out the form
      this.options.$inline.empty();

      // Show Source pane
      this.options.$inline.hide();
      this.options.$help.hide();
      this.options.$preview.show();
      this.$source.show();
    },

    // --------------------------------------------------- Other event handlers

    // Triggered by window resize events
    _onFullScreenResize: function(){
      if (this.options.fullscreen === false) return;

      var hfix = 65;
      var height = $(window).height() - hfix;

      this.options.$wrap.width($(window).width()-20);
    },

    _serializedFormData: function() {
      return JSON.stringify( $('[name^=item_form]', this.options.$inline).serializeArray() );
    }
  };

  // A really lightweight plugin wrapper around the constructor,
  // preventing against multiple instantiations
  $.fn[pluginName] = function ( options ) {
    return this.each(function () {
      if (!$.data(this, 'plugin_' + pluginName)) {
        $.data(this, 'plugin_' + pluginName, new Plugin( this, options ));
      }
    });
  };
}(jQuery, window));
