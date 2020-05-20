document.addEventListener('turbolinks:load', function() {
  var $activitiesGroupsContainer = $('[data-behavior="activities-groups-container"]');
  var loading = false;

  if ($activitiesGroupsContainer.length) {
    var $viewContent = $('[data-behavior="view-content"]');

    $viewContent.on('scroll', function() {
      var canLoadMore = $activitiesGroupsContainer.data('canLoadMore');
      var scrollHeight = $viewContent[0].scrollHeight;
      var scrollTop = $viewContent.scrollTop();
      var viewHeight = $viewContent.height();

      // 64px is the sum of margin bottom and padding bottom of the content-container class
      if (canLoadMore && !loading && viewHeight + scrollTop >= (scrollHeight - 64)) {
        var page = $activitiesGroupsContainer.data('page') + 1;
        var url = $activitiesGroupsContainer.data('url');
        loading = true;
        $('[data-behavior="activities-spinner"]').show();

        $.ajax({
          url: url,
          data: { page: page },
          success: function(data) {
            loading = false;
            $('[data-behavior="activities-spinner"]').hide();
          }
        })
      }
    });
  }
});
