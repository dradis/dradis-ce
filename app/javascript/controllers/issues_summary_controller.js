import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['chart', 'group', 'selector']
  static values = { storageKey: String, url: String }

  connect() {
    if (this.element.src) return;

    const url = new URL(this.urlValue, window.location.origin);
    try {
      const grouping = localStorage.getItem(this.storageKeyValue);
      if (grouping) url.searchParams.set('grouping', grouping);
    } catch {
      // Storage is optional; the widget still loads with the default grouping.
    }
    this.element.src = url.toString();
  }

  change(event) {
    this.remember(event.target.value);
    event.target.form.requestSubmit();
  }

  chartTargetConnected(element) {
    const groups = JSON.parse(element.dataset.groups);
    const color = group => group.color || 'var(--untagged-color)';
    const margin = { top: 20, bottom: 0 };
    const width = 354;
    const height = 180 - margin.top - margin.bottom;
    const x = d3.scaleBand().domain(groups.map(group => group.key)).rangeRound([0, width]);
    const y = d3.scaleLinear().domain([0, Math.max(1, ...groups.map(group => group.count))]).range([height, 0]);
    const svg = d3.select(element).append('svg')
      .attr('width', width)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', `translate(0,${margin.top})`);

    const bars = svg.append('g');
    bars.selectAll('[data-behavior~=issue-chart-bar]')
      .data(groups)
      .enter().append('rect')
      .attr('data-behavior', 'issue-chart-bar')
      .attr('fill', color)
      .attr('x', group => x(group.key))
      .attr('width', x.bandwidth())
      .attr('y', group => y(group.count))
      .attr('height', group => height - y(group.count));

    bars.selectAll('[data-behavior~=issue-chart-count]')
      .data(groups)
      .enter().append('text')
      .attr('data-behavior', 'issue-chart-count')
      .attr('fill', color)
      .attr('x', group => x(group.key) + x.bandwidth() / 2)
      .attr('y', group => y(group.count))
      .attr('dy', -5)
      .attr('text-anchor', 'middle')
      .text(group => group.count);

    // A wrapping legend stays readable with many groups or long names, where
    // x-axis labels would overlap.
    const items = d3.select(element).append('ul')
      .attr('class', 'issue-chart-legend')
      .selectAll('[data-behavior~=issue-chart-legend-item]')
      .data(groups)
      .enter().append('li')
      .attr('class', 'issue-chart-legend-item')
      .attr('data-behavior', 'issue-chart-legend-item')
      .attr('title', group => group.name)
      .style('--issue-group-color', group => group.color);

    items.append('span').attr('class', 'issue-chart-legend-swatch');
    items.append('span').attr('class', 'issue-chart-legend-label').text(group => group.name);
  }

  chartTargetDisconnected(element) {
    element.replaceChildren();
  }

  groupTargetConnected(element) {
    if (element.dataset.groupColor) {
      element.style.setProperty('--issue-group-color', element.dataset.groupColor);
    }
  }

  remember(grouping) {
    try {
      localStorage.setItem(this.storageKeyValue, grouping);
    } catch {
      // Changing the grouping does not require persistent browser storage.
    }
  }

  selectorTargetConnected(element) {
    // Remember the server's fallback if the saved field no longer exists.
    this.remember(element.value);
  }
}
