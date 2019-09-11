class MethodologyImportService

  def initialize(project_id)
    @project_id = project_id
  end

  def import(methodology, board_name: nil, node: nil)
    ActiveRecord::Base.transaction do
      # create a board for each methodology
      board = Board.new(
        name: board_name || methodology.name,
        node: node || Project.find(@project_id).methodology_library,
        project_id: @project_id
      )

      # create lists (lists fom methodology already have cards)
      methodology.lists.map do |list|
        board.lists << list
      end

      board.save!

      order_lists_and_cards(board)
    end
  end

  private

  def order_lists_and_cards(board)
    previous_list_id = nil
    board.lists.each do |list|
      previous_card_id = nil
      list.cards.each do |card|
        card.previous_id = previous_card_id
        card.save!
        previous_card_id = card.id
      end

      list.previous_id = previous_list_id
      list.save!
      previous_list_id = list.id
    end
  end
end
