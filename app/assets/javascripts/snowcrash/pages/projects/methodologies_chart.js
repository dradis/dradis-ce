document.addEventListener('turbolinks:load', function(){
  var $dataElement  = $('#methodology-chart-data'),
      $chartElement = $('#methodology-chart');

  if ($dataElement.length && $chartElement.find('svg').length == 0) {
    var total_tasks     = $dataElement.data('total');
    var completed_tasks = $dataElement.data('completed');

    var width         = 200,
        height        = 200,
        twoPi         = 2 * Math.PI,
        radius        = Math.min(width, height) / 2,
        formatPercent = d3.format('.0%'),
        progress      = 0;

        if (total_tasks > 0) {
          progress = (completed_tasks * 100 / total_tasks)/100;
        }

    var arc4 = d3.svg.arc()
        .startAngle(0)
        .innerRadius(radius - 10)
        .outerRadius(radius - 40);

    var svg4 = d3.select('#methodology-chart').append('svg')
        .attr('width', width)
        .attr('height', height)
      .append('g')
        .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');

    var meter = svg4.append('g')
        .attr('class', 'progress-meter');

    meter.append('path')
        .attr('class', 'background')
        .attr('d', arc4.endAngle(twoPi));

    var foreground = meter.append('path')
        .attr('class', 'foreground');

    var text = meter.append('text')
        .attr('text-anchor', 'middle')
        .attr('dy', '.35em');

    foreground.attr('d', arc4.endAngle(twoPi * progress));
    text.text(formatPercent(progress));
  }
});
