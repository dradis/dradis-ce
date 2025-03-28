document.addEventListener('turbo:load', function () {
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
        var url = $infiniteScrollContainer.data('url');
        var user_id = $infiniteScrollContainer.data('userId');
        var trackable_type = $infiniteScrollContainer.data('trackableType');
        var start_date = $infiniteScrollContainer.data('startDate');
        var end_date = $infiniteScrollContainer.data('endDate');
        var specific_date = $infiniteScrollContainer.data('specificDate');

        loading = true;
        $('[data-behavior="activities-spinner"]').show();

        $.ajax({
          url: url,
          data: { page: page, user_id: user_id, trackable_type: trackable_type, start_date: start_date, end_date: end_date, specific_date: specific_date },
          success: function (data) {
            loading = false;
            $('[data-behavior="activities-spinner"]').hide();
          },
        });
      }
    });
  }
});
