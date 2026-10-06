(() => {
  const initIssuesChart = () => {
    const $dataElement = $('[data-behavior="issues-summary-data"]');
    const $chartElement = $('.issue-chart');

    if (!$dataElement.length || $chartElement.find('svg').length) return;

    const margin = { top: 20, bottom: 0 };
    const width = 354;
    const height = 180 - margin.top - margin.bottom;
    const x = d3.scaleBand().rangeRound([0, width]);
    const y = d3.scaleLinear().range([height, 0]);
    const container = d3.select($chartElement[0]);
    const svg = container
      .append('svg')
      .attr('width', width)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', `translate(0,${margin.top})`);

    const groups = $dataElement.data('groups');
    const data = groups.map(group => ({
      letter: group.name,
      frequency: group.count,
    }));
    const xDomain = data.map(d => d.letter);
    const highest = Math.max(...data.map(d => d.frequency));

    x.domain(xDomain);
    y.domain([0, highest]);

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
      ['.bar', '.counter'].forEach(selector => {
        const $element = $chartElement.find(selector).eq(index);

        if (group.unassigned) {
          $element.addClass('untagged');
        } else {
          $element.attr('fill', group.color);
        }
      });
    });

    buildLegend(container, groups);
  };

  const buildLegend = (container, groups) => {
    const items = container
      .append('ul')
      .attr('class', 'issue-chart-legend')
      .selectAll('li')
      .data(groups)
      .enter()
      .append('li')
      .attr('class', group => (group.unassigned ? 'legend-item untagged' : 'legend-item'))
      .attr('title', group => group.name);

    items
      .append('span')
      .attr('class', 'legend-swatch')
      .style('background-color', group => (group.unassigned ? null : group.color));

    items
      .append('span')
      .attr('class', 'legend-label')
      .text(group => group.name);
  };

  document.addEventListener('turbo:frame-load', initIssuesChart);
})();
