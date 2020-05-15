document.addEventListener('turbolinks:load', function() {
  var $activitiesGroupsContainer = $('[data-behavior="activities-groups-container"]');
  var loading = false;
  var canLoadMore = true;

  if ($activitiesGroupsContainer.length) {
    var $viewContent = $('[data-behavior="view-content"]');

    $viewContent.on('scroll', function() {
      var viewHeight = $viewContent.height();
      var scrollTop = $viewContent.scrollTop();
      var scrollHeight = $viewContent[0].scrollHeight;

      // 64px is the sum of margin bottom and padding bottom of the content-container class
      if (canLoadMore && !loading && viewHeight + scrollTop >= (scrollHeight - 64)) {
        var page = $activitiesGroupsContainer.data('page') + 1;
        var url = $activitiesGroupsContainer.data('url');
        $('[data-behavior="activities-spinner"]').show();
        loading = true;

        $.ajax({
          url: url,
          data: { page: page },
          success: function(data, status, XHR) {
            var $activitiesGroups = $(data);

            if ($activitiesGroups.length) {
              $activitiesGroupsContainer.data('page', page);

              var activityDayValues = $.map($('[data-behavior~=activity-day-value]'), function(element, index) {
                return $(element).text();
              })

              $.each($activitiesGroups, function(index, activitiesGroup) {
                var $activitiesGroup = $(activitiesGroup);
                var timeElementDatetime = $activitiesGroup.find('[data-behavior~=activity-day-value]').attr('datetime');
                var timeElementInDOM = $activitiesGroupsContainer.find(`[datetime="${timeElementDatetime}"]`);

                // Check if DOM has the time element with this datetime attribute
                if (timeElementInDOM.length) {
                  var $activitiesGroupContainer = timeElementInDOM.parents('[data-behavior="activities-group"]');
                  var $activities = $activitiesGroupContainer.find('[data-behavior="activities"]');

                  $.each($activitiesGroup.find('[data-behavior="activity"]'), function(index, element) {
                    $activities.append(element);
                  })
                } else {
                  $activitiesGroupsContainer.append(activitiesGroup);
                }
              })
            } else {
              canLoadMore = false;
            }

            loading = false;
            $('[data-behavior="activities-spinner"]').hide();
          }
        })
      }
    });
  }
});
