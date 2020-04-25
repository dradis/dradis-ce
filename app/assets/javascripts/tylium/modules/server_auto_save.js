// Server Auto Save module is initialized on elements with
// data-behavior=server-auto-save. This module creates an action cable
// subscription bound to the editor it's initialized from. The socket will
// accept content for resources to update, and create revisions from. It will
// receive timestamps back from the server to update the `original_updated_at`
// field which helps us with conflict resolution.
(function($, window) {
  function ServerAutoSave(form) {
    this.form = form;

    this.projectId = form.dataset.asProjectId;
    this.resourceType = form.dataset.asResourceType;
    this.resourceId = form.dataset.asResourceId;
    this.originalUpdatedAt = form.querySelector('[data-behavior~=updated-as-auto-save]');
    this._doneTypingInterval = 500;
    this._autoSaveTimedInterval = 60000;

    this.init();
  }

  ServerAutoSave.prototype = {
    init: function() {
      var that = this;
      this.editorChannel = window.App.cable.subscriptions.create({
        channel: 'EditorChannel',
        project_id: this.projectId,
        resource_id: this.resourceId,
        resource_type: this.resourceType
      },{
        connected: function() {
          console.log('Subscribed to EditorChannel');
        },
        rejected: function() {
          console.log('Error subscribing to EditorChannel');
        },
        save: function() {
          this.perform('save', { data: $(that.form).serialize() });
        },
        received: function(newUpdatedAtTime) {
          that.originalUpdatedAt.value = newUpdatedAtTime;
        }
      })

      this.behaviors();
    },
    behaviors: function() {
      // When we navigate away form the page tidy up the channel
      this._cleanupBound = this.cleanup.bind(this);
      document.addEventListener('turbolinks:before-cache', this._cleanupBound)

      // we're using a jQuery plugin for :textchange event, so need to use $()
      this._changeTimeoutBound = this._changeTimeout.bind(this);
      $(this.form).on('textchange', this._changeTimeoutBound);

      // A save every 60 seconds?
      // this._saveInterval = setInterval(this._changeTimeout.bind(this), this._autoSaveTimedInterval);
    },
    cleanup: function() {
      clearInterval(this._saveInterval); // Clear out the save timer
      this.editorChannel.save(); // Save the results once more

      document.removeEventListener('turbolinks:before-cache', this._cleanupBound)
      this.form.removeEventListener('textchange', this._changeTimeoutBound)

      this.editorChannel.unsubscribe(); // Unsubscribe from the channel
      window.App.cable.subscriptions.remove(this.editorChannel); // Clean up the subscriptions
    },
    _changeTimeout: function() {
      clearTimeout(this._typingTimer);
      this._typingTimer = setTimeout(function() {
        this.editorChannel.save();
      }.bind(this), this._doneTypingInterval);
    }
  }

  window.ServerAutoSave = ServerAutoSave;
})(jQuery, window);
