(() => {
  const initIssuesChart = () => {
    const $dataElement = $('[data-behavior="issues-summary-data"]');
    const $chartElement = $('.issue-chart');

    if (!$dataElement.length || $chartElement.find('svg').length) return;

    const margin = { top: 20, bottom: 30 };
    const width = 354;
    const height = 180 - margin.top - margin.bottom;
    const x = d3.scaleBand().rangeRound([0, width]);
    const y = d3.scaleLinear().range([height, 0]);
    const xAxis = d3.axisBottom(x).tickSize(0);
    const svg = d3
      .select($chartElement[0])
      .append('svg')
      .attr('width', width)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', `translate(0,${margin.top})`);

    const groups = $dataElement.data('groups');
    const data = groups.map(group => ({
      letter: group.unassigned ? 'N/A' : group.name,
      frequency: group.count,
    }));
    const xDomain = data.map(d => d.letter);
    const highest = Math.max(...data.map(d => d.frequency));

    x.domain(xDomain);
    y.domain([0, highest]);

    const xAxisGroup = svg
      .append('g')
      .attr('class', 'x axis')
      .attr('transform', `translate(0,${height})`)
      .call(xAxis);

    xAxisGroup.selectAll('text').style('fill', 'inherit');
    xAxisGroup.selectAll('path').style('stroke', 'none');

    const bars = svg.append('g');

    bars
      .selectAll('rect')
      .data(data)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', d => x(d.letter))
      .attr('width', x.bandwidth())
      .attr('y', d => y(d.frequency))
      .attr('height', d => height - y(d.frequency));

    bars
      .selectAll('text')
      .data(data)
      .enter()
      .append('text')
      .attr('x', d => x(d.letter) + x.bandwidth() / 2)
      .attr('y', d => y(d.frequency))
      .attr('dy', -5)
      .attr('text-anchor', 'middle')
      .attr('class', 'counter')
      .text(d => d.frequency);

    groups.forEach((group, index) => {
      ['.tick', '.bar', '.counter'].forEach(selector => {
        const $element = $chartElement.find(selector).eq(index);

        if (group.unassigned) {
          $element.addClass('untagged');
        } else {
          $element.attr('fill', group.color);
        }
      });
    });
  };

  document.addEventListener('turbo:frame-load', initIssuesChart);
})();
