module Card::Position
  extend ActiveSupport::Concern

  def move_to(new_list_id: nil, prev_id: nil, next_id: nil)
    destination = board.lists.find(new_list_id.presence || list_id)
    append = new_list_id.present? && prev_id.blank? && next_id.blank?
    return false if append && destination == list

    self.class.transaction do
      prev_id = destination.last_card&.id if append
      destination.move(self, prev_id: prev_id, next_id: next_id)
      update!(list: destination) if new_list_id.present?
    end

    true
  end
end
