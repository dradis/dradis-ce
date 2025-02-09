document.addEventListener('turbolinks:load', function () {
  var $infiniteScrollContainer = $(
    '[data-behavior="infinite-scroll-container"]'
  );
  var loading = false;

  if ($infiniteScrollContainer.length) {
    // Attach the scroll event to the window instead of a specific element
    $(window).on('scroll', function () {
      var canLoadMore = $infiniteScrollContainer.data('canLoadMore');
      var scrollTop = window.scrollY || document.documentElement.scrollTop;
      var scrollHeight = document.documentElement.scrollHeight;
      var viewHeight = window.innerHeight;

      // 64px is the sum of margin bottom and padding bottom of the content-container class
      if (
        canLoadMore &&
        !loading &&
        viewHeight + scrollTop >= scrollHeight - 64
      ) {
        var page = $infiniteScrollContainer.data('page') + 1;
        var userId = $('#user_id').val();
        var startDate = $('#start_date').val();
        var endDate = $('#end_date').val();
        var trackableType = $('#trackable_type').val();
        var url = $infiniteScrollContainer.data('url') + '?user' + userId + 'start_date=' + startDate + '&end_date=' + endDate + '&trackable_type' + trackableType;
        loading = true;
        $('[data-behavior="activities-spinner"]').show();

        $.ajax({
          url: url,
          data: { page: page, user_id: userId, start_date: startDate, end_date: endDate, trackable_type: trackableType },
          success: function (data) {
            loading = false;
            $('[data-behavior="activities-spinner"]').hide();
          },
        });
      }
    });
  }

  // Jquery
  $(document).ready(function() {
    $('#reset_button').on('click', function(){
      var actualUrl = window.location.pathname;

      history.replaceState(null, null, actualUrl);

      window.location.reload()
    })
  })
});
