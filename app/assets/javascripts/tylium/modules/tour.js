document.addEventListener("turbolinks:load", function(){

  (function($, window){
    function Tour(){ this.init(); };

    Tour.prototype = {
      init: function() {
        this.behaviors();
      },
      behaviors: function() {
        $('[data-behavior~=tour-start]').on('click', this.onStart);
        $('[data-behavior~=tour-step]').on('click', this.onStep);
      },
      onStep: function(event) {
        var nextStep = $(this).data('tour-next');
        $('.modal.show').modal('hide');
        $('[data-behavior~=tour-step-' + nextStep + ']').modal({})
      },
      onStart: function(event) {
        $('[data-behavior=tour-step-one]').modal({});
      }
    }

    // We always want a tour, as there are tour-start links that would trigger it
    var tour = new Tour();

    if ($('[data-behavior~=show-tour]').length) {
      tour.onStart();
    }

  })(jQuery, window);

});