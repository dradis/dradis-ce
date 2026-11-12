module ActsAsLinkedList
  extend ActiveSupport::Concern

  def first_item
    @first_item ||= self.items.find_by(previous_id: nil)
  end

  def last_item
    @last_item ||= self.ordered_items.last
  end

  def move(item, prev_id: nil, next_id: nil)
    prev_item = items.find_by(id: prev_id)
    next_item = items.find_by(id: next_id)
    unless valid_position?(item, prev_item, next_item, prev_id: prev_id, next_id: next_id)
      item.errors.add(:base, 'Position must reference adjacent items in the destination')
      raise ActiveRecord::RecordInvalid, item
    end

    item.class.transaction do
      old_next_item = item.send("next_#{item.class.name.downcase}")
      old_next_item.update_attribute(:previous_id, item.previous_id) if old_next_item

      item.update_attribute(:previous_id, prev_item&.id)
      next_item.update_attribute(:previous_id, item.id) if next_item
    end
  end

  def ordered_items
    return [] if first_item.nil?

    current_item = first_item
    items = [current_item]
    while (next_item = self.items.find_by(previous_id: current_item.id)) do
      items << next_item
      current_item = next_item
    end

    items
  end

  class_methods do
    def list_item_name(name)
      names = name.to_s.pluralize

      # alias_attribute :items, names.to_sym
      # Rails 7.2 deprecated non-attribute alias_attributes: https://github.com/rails/rails/pull/48972
      # There may be an update coming for this: https://github.com/rails/rails/pull/49801
      # But it has not yet been merged. Until then, we must define the association again here:
      has_many :items, class_name: name.to_s.titleize

      alias_method "first_#{name}".to_sym, :first_item
      alias_method "last_#{name}".to_sym, :last_item
      alias_method "ordered_#{names}".to_sym, :ordered_items
    end
  end

  private

  def valid_position?(item, prev_item, next_item, prev_id:, next_id:)
    return false if prev_id.present? && prev_item.nil?
    return false if next_id.present? && next_item.nil?
    return false if prev_item == item || next_item == item

    items.find_by(previous_id: prev_item&.id) == next_item
  end
end
