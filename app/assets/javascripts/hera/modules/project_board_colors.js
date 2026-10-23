function loadProjectBoardColors() {
  $('[data-behavior~=board-progress]').each(function (i, board) {
    $(board)
      .find('[data-behavior~=list-progress]')
      .each(function (index, list) {
        $(list).css('background-color', d3.schemeCategory20[index]);
      });
  });
}

document.addEventListener('turbo:load', function () {
  if ($('[data-behavior~=board-progress]').length) {
    loadProjectBoardColors();
  }
});
