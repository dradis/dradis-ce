(() => {
  const initIssuesChart = () => {
    const $dataElement = $('[data-behavior="issues-summary-data"]');
    const $chartElement = $('[data-behavior~="issue-chart"]');

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

    const tags = $dataElement.data('tags');
    const issuesByTag = $dataElement.data('issues-count');
    let highest = 0;
    const data = [];
    const xDomain = [];

    for (const key in tags) {
      const issuesCount = issuesByTag[key];
      highest = issuesCount > highest ? issuesCount : highest;
      data.push({ letter: tags[key][0], frequency: issuesCount });
      xDomain.push(tags[key][0]);
    }

    data.push({ letter: 'N/A', frequency: issuesByTag.unassigned });
    xDomain.push('N/A');

    x.domain(xDomain);
    y.domain([0, Math.max(highest, issuesByTag.unassigned)]);

    const xAxisGroup = svg
      .append('g')
      .attr('class', 'x axis')
      .attr('transform', `translate(0,${height})`)
      .call(xAxis);

    xAxisGroup.selectAll('text').style('fill', 'inherit');
    xAxisGroup.selectAll('path').style('stroke', 'none');
    xAxisGroup
      .selectAll('text')
      .filter((d, index, nodes) => index === nodes.length - 1)
      .classed('untagged', true);

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

    Object.keys(tags).forEach((key, index) => {
      $chartElement.find('.tick').eq(index).attr('fill', tags[key][1]);
      $chartElement.find('.bar').eq(index).attr('fill', tags[key][1]);
      $chartElement.find('.counter').eq(index).attr('fill', tags[key][1]);
    });

    const untaggedIndex = Object.keys(tags).length;
    $chartElement.find('.tick').eq(untaggedIndex).addClass('untagged');
    $chartElement.find('.bar').eq(untaggedIndex).addClass('untagged');
    $chartElement.find('.counter').eq(untaggedIndex).addClass('untagged');
  };

  document.addEventListener('turbo:load', initIssuesChart);
  document.addEventListener('turbo:frame-load', initIssuesChart);
})();
