document.addEventListener('turbolinks:load', function() {
  var $allActivitiesContainer = $('.all-activities-container');
  var loading = false;
  var canLoadMore = true;

  if ($allActivitiesContainer.length) {
    var $viewContent = $('#view-content');

    $viewContent.on('scroll', function() {
      var viewHeight = $viewContent.height();
      var scrollTop = $viewContent.scrollTop();
      var scrollHeight = $viewContent[0].scrollHeight;

      // 64px is the sum of margin bottom and padding bottom of the content-container class
      if (canLoadMore && !loading && viewHeight + scrollTop >= (scrollHeight - 64)) {
        var page = $allActivitiesContainer.data('page') + 1;
        var url = $allActivitiesContainer.data('url');
        $('.spinner-container').show();
        loading = true;

        $.ajax({
          url: url + '.js',
          data: { page: page },
          success: function(data, status, XHR) {
            var $activitiesGroups = $(data);

            if ($activitiesGroups.length) {
              $allActivitiesContainer.data('page', page);

              var activityDayValues = $.map($('[data-behavior~=activity-day-value]'), function(element, index) {
                return $(element).text();
              })

              $.each($activitiesGroups, function(index, activitiesGroup) {
                var $activitiesGroup = $(activitiesGroup);
                var timeElementDatetime = $activitiesGroup.find('[data-behavior~=activity-day-value]').attr('datetime');
                var timeElementInDOM = $allActivitiesContainer.find(`[datetime="${timeElementDatetime}"]`);

                // Check if DOM has the time element with this datetime attribute
                if (timeElementInDOM.length) {
                  var $activitiesGroupContainer = timeElementInDOM.parents('.activities-group-container');
                  $.each($activitiesGroup.find('.activity'), function(index, element) {
                    $activitiesGroupContainer.find('.activities-group').append(element);
                  })
                } else {
                  $allActivitiesContainer.append(activitiesGroup);
                }
              })
            } else {
              canLoadMore = false;
            }

            loading = false;
            $('.spinner-container').hide();
          }
        })
      }
    });
  }
});
