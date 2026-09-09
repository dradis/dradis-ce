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

    const tags = $dataElement.data('tags');
    const issuesByTag = $dataElement.data('issues-count');
    let highest = 0;
    const data = [];
    const xDomain = [];
    const colors = [];

    for (const key in tags) {
      const issuesCount = issuesByTag[key];
      highest = issuesCount > highest ? issuesCount : highest;
      data.push({ letter: tags[key][0], frequency: issuesCount });
      xDomain.push(tags[key][0]);
      colors.push(tags[key][1]);
    }

    data.push({ letter: 'N/A', frequency: issuesByTag.unassigned });
    xDomain.push('N/A');

    x.domain(xDomain);
    y.domain([0, Math.max(highest, issuesByTag.unassigned)]);

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

    colors.forEach((color, index) => {
      $chartElement.find('.bar').eq(index).attr('fill', color);
      $chartElement.find('.counter').eq(index).attr('fill', color);
    });

    $chartElement.find('.bar').eq(colors.length).addClass('untagged');
    $chartElement.find('.counter').eq(colors.length).addClass('untagged');

    buildLegend(container, data, colors);
  };

  const buildLegend = (container, data, colors) => {
    const legendItems = container
      .append('ul')
      .attr('class', 'issue-chart-legend')
      .selectAll('li')
      .data(data)
      .enter()
      .append('li')
      .attr('class', (_, index) => (index === colors.length ? 'legend-item untagged' : 'legend-item'))
      .attr('title', d => d.letter);

    legendItems
      .append('span')
      .attr('class', 'legend-swatch')
      .style('background-color', (_, index) => colors[index] || null);

    legendItems
      .append('span')
      .attr('class', 'legend-label')
      .text(d => d.letter);
  };

  document.addEventListener('turbo:load', initIssuesChart);
  document.addEventListener('turbo:frame-load', initIssuesChart);
})();
