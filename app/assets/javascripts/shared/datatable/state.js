$(document).on('preInit.dt', 'body.issues.index', function (e, settings) {
  var $paths = $('[data-behavior~=datatable-paths]');
  if ($paths.data('table-state-url') == undefined) {
    return;
  }

  var api = new $.fn.dataTable.Api(settings);

  api.button().add(1, {
    attr: {
      'data-behavior': 'table-action',
    },
    autoClose: true,
    className: 'd-none',
    extend: 'collection',
    name: 'stateBtn',
    text: '<i class="fa fa-adjust fa-fw"></i>State<i class="fa fa-caret-down fa-fw"></i>',
    buttons: DradisDatatable.prototype.setupStateButtons.call(api),
  });
});

$(document).on('init.dt', 'body.issues.index', function (e, settings) {
  var $paths = $('[data-behavior~=datatable-paths]');
  if ($paths.data('table-state-url') == undefined) {
    return;
  }

  var api = new $.fn.dataTable.Api(settings);
  api.on(
    'select.dt deselect.dt',
    function () {
      var selectedCount = this.rows({ selected: true }).count();
      DradisDatatable.prototype.toggleStateBtn.call(api, selectedCount !== 0);
    }.bind(api)
  );
});

DradisDatatable.prototype.setupStateButtons = function () {
  var states = [
      ['Draft', 'fa-pencil-square-o'],
      ['Ready for review', 'fa-eye'],
      ['Published', 'fa-rocket'],
    ],
    stateButtons = [],
    api = this;

  if ($('[data-behavior~=qa-viewer]').length > 0) {
    states.splice(1, 1);
  }

  states.forEach(function (state) {
    stateButtons.push({
      text: $(
        `<i class="fa ${state[1]} fa-fw mr-1"></i><span>${state[0]}</span>`
      ),
      action: DradisDatatable.prototype.updateRecordState.call(
        api,
        state[0].toLowerCase().replaceAll(' ', '_')
      ),
    });
  });

  return stateButtons;
};

DradisDatatable.prototype.updateRecordState = function (newState) {
  var api = this;

  return function () {
    var $paths = $('[data-behavior~=datatable-paths]');
    var selectedRows = this.rows({ selected: true });

    $.ajax({
      url: $paths.data('table-state-url'),
      method: 'PUT',
      data: {
        ids: DradisDatatable.prototype.rowIds(selectedRows),
        state: newState,
      },
      success: function () {
        DradisDatatable.prototype.toggleStateBtn.call(api, false);

        selectedRows.deselect().remove().draw();

        $('[data-behavior="qa-alert"]').remove();
        $('.page-title').after(`
          <div class="alert alert-success" data-behavior="qa-alert">
            <a class="close" data-dismiss="alert" href="javascript:void(0)">x</a>
            Successfully set the records as ${newState}!
          </div>
        `);
      },
      error: function (xhr, status, msg) {
        console.log('Update state error: ' + msg);
      },
    });
  }.bind(this);
};

DradisDatatable.prototype.toggleStateBtn = function (isShown) {
  var stateBtn = this.buttons('stateBtn:name');
  $(stateBtn[0].node).toggleClass('d-none', !isShown);
};
