// Built before the DataTable is initialized, so DataTables treats the filter
// row as part of the header and hides its cells along with their columns.
DradisDatatable.prototype.buildColumnFilters = function () {
  this.$columnFilters = $('<tr class="column-filters d-none"></tr>');

  this.tableHeaders.forEach((th, index) => {
    const $cell = $('<td></td>');

    if (th.dataset.columnVisible !== 'false') {
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

// Closing the filters also clears them, so rows are never filtered by inputs
// the user can't see.
DradisDatatable.prototype.setColumnFiltersVisibility = function (isVisible) {
  const button = this.dataTable.button('columnFiltersBtn:name');

  this.$columnFilters.toggleClass('d-none', !isVisible);
  button.text(
    `<i class="fa-solid fa-filter me-1 fa-fw"></i>Filters: ${isVisible ? 'On' : 'Off'}`
  );
  $(button.node()).attr('aria-pressed', isVisible);

  if (!isVisible) {
    this.$columnFilterInputs.val('');
    // Keep the current page, as clearing empty filters changes no rows
    this.dataTable.columns().search('').draw(false);
  }
};

DradisDatatable.prototype.setupColumnFilters = function () {
  // Show the filters restored by stateSave
  this.$columnFilterInputs.each((_index, input) => {
    input.value = this.dataTable.column(input.dataset.column).search();
  });

  if (this.$columnFilterInputs.filter((_index, input) => input.value).length) {
    this.setColumnFiltersVisibility(true);
  }

  this.$columnFilterInputs.on('input', (event) => {
    const input = event.target;
    this.dataTable.column(input.dataset.column).search(input.value).draw();
  });

  // Hiding a column also clears its filter, so rows are never filtered by
  // inputs the user can't see.
  this.dataTable.on('column-visibility.dt', (_event, _settings, column, isVisible) => {
    if (!isVisible && this.dataTable.column(column).search()) {
      this.$columnFilterInputs.filter(`[data-column=${column}]`).val('');
      this.dataTable.column(column).search('').draw(false);
    }
  });
};
