function initIssuesChart() {
  const $chartElement = $('[data-behavior~=issue-chart]');

  if (!$chartElement.length || $chartElement.find('svg').length > 0) { return; }

  const margin = { top: 20, bottom: 0 };
  const width  = 354;
  const height = 180 - margin.top - margin.bottom;

  const x = d3.scaleBand().rangeRound([0, width]);
  const y = d3.scaleLinear().range([height, 0]);

  const container = d3.select('[data-behavior~=issue-chart]');

  const svg = container.append('svg')
      .attr('width', width)
      .attr('height', height + margin.top + margin.bottom)
    .append('g')
      .attr('transform', `translate(0,${margin.top})`);

  // --------------------------------------------------------- Data variables
  const tags = $chartElement.data('tags') || {};
  const issuesByTag = $chartElement.data('issues-count') || {};
  let highest = 0;
  const data = [];
  const x_domain = [];
  const colors = [];

  Object.keys(tags).forEach(key => {
    const issuesCount = issuesByTag[key] || 0;
    highest = issuesCount > highest ? issuesCount : highest;
    data.push({ letter: tags[key][0], frequency: issuesCount });
    x_domain.push(tags[key][0]);
    colors.push(tags[key][1]);
  });

  const unassignedCount = issuesByTag['unassigned'] || 0;
  data.push({ letter: 'N/A', frequency: unassignedCount });
  x_domain.push('N/A');

  const highest_y = Math.max(highest, unassignedCount);
  // -------------------------------------------------------- /Data variables

  x.domain(x_domain);
  y.domain([0, highest_y]);

  const bars = svg.append('g');

  bars.selectAll('rect')
      .data(data)
    .enter().append('rect')
      .attr('class', 'bar')
      .attr('x', d => x(d.letter))
      .attr('width', x.bandwidth())
      .attr('y', d => y(d.frequency))
      .attr('height', d => height - y(d.frequency));

  bars.selectAll('text')
      .data(data)
    .enter().append('text')
      .attr('x', d => x(d.letter) + x.bandwidth() / 2)
      .attr('y', d => y(d.frequency))
      .attr('dy', -5)
      .attr('text-anchor', 'middle')
      .attr('class', 'counter')
      .text(d => d.frequency);

  colors.forEach((color, i) => {
    $($('.bar')[i]).attr('fill', color);
    $($('.counter')[i]).attr('fill', color);
  });

  $($('.bar')[colors.length]).addClass('untagged');
  $($('.counter')[colors.length]).addClass('untagged');

  buildLegend(container, data, colors);
}

function buildLegend(container, data, colors) {
  const legend = container.append('ul').attr('class', 'issue-chart-legend');

  const item = legend.selectAll('li')
      .data(data)
    .enter().append('li')
      .attr('class', (_, i) => i === colors.length ? 'legend-item untagged' : 'legend-item')
      .attr('title', d => d.letter);

  item.append('span')
    .attr('class', 'legend-swatch')
    .style('background-color', (_, i) => colors[i] || null);

  item.append('span')
    .attr('class', 'legend-label')
    .text(d => d.letter);
}

document.addEventListener('turbo:load', initIssuesChart);
