// Built before the DataTable is initialized, so DataTables treats the filter
// row as part of the header and hides its cells along with their columns.
DradisDatatable.prototype.buildColumnFilters = function () {
  this.$columnFilters = $('<tr class="column-filters d-none"></tr>');

  this.tableHeaders.forEach((th, index) => {
    const $cell = $('<td></td>');

    if (th.dataset.columnVisible != 'false') {
      const columnName = th.textContent.trim();

      $('<input type="search" class="form-control form-control-sm" data-behavior="column-filter">')
        .attr({
          'aria-label': `Filter ${columnName}`,
          'data-column': index,
          placeholder: `Filter by ${columnName}...`,
        })
        .appendTo($cell);
    }

    this.$columnFilters.append($cell);
  });

  $(this.tableHeaders[0].parentElement).after(this.$columnFilters);

  // DataTables detaches the cells of hidden columns, so keep a reference to
  // every input while they're all still in the row.
  this.$columnFilterInputs = this.$columnFilters.find('[data-behavior~=column-filter]');
};

DradisDatatable.prototype.setupColumnFilters = function () {
  this.$columnFilterInputs.each((_index, input) => {
    const column = this.dataTable.column(input.dataset.column);

    if (column.visible()) {
      input.value = column.search();
    } else if (column.search()) {
      column.search('').draw();
    }
  });

  if (this.$columnFilterInputs.filter((_index, input) => input.value).length) {
    this.setColumnFiltersVisibility(true);
  }

  this.$columnFilterInputs.on('input', (event) => {
    const input = event.target;
    this.dataTable.column(input.dataset.column).search(input.value).draw();
  });

  this.dataTable.on('column-visibility.dt', (_event, _settings, columnIndex, isVisible) => {
    if (!isVisible) {
      this.$columnFilterInputs.filter(`[data-column=${columnIndex}]`).val('');
      this.dataTable.column(columnIndex).search('').draw();
    }
  });
};

// Hiding the filters (or a column) also clears them, so rows are never
// filtered by inputs the user can't see.
DradisDatatable.prototype.setColumnFiltersVisibility = function (isVisible) {
  const button = this.dataTable.button('columnFiltersBtn:name');

  this.$columnFilters.toggleClass('d-none', !isVisible);
  button.text(
    `<i class="fa-solid fa-filter me-1 fa-fw"></i>Filters: ${isVisible ? 'On' : 'Off'}`
  );
  $(button.node()).attr('aria-expanded', isVisible);

  if (!isVisible) {
    this.$columnFilterInputs.val('');
    this.dataTable.columns().search('').draw();
  }
};

DradisDatatable.prototype.toggleColumnFilters = function () {
  const isVisible = this.$columnFilters.hasClass('d-none');

  this.setColumnFiltersVisibility(isVisible);

  if (isVisible) {
    // Only inputs of visible columns are in the row
    this.$columnFilters.find('[data-behavior~=column-filter]').first().trigger('focus');
  }
};
