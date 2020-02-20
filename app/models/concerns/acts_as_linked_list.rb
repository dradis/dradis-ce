module ActsAsLinkedList
  extend ActiveSupport::Concern

  def first_item
    @first_item ||= self.items.find_by(previous_id: nil)
  end

  def last_item
    @last_item ||= self.ordered_items.last
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

      alias_attribute :items, names.to_sym
      alias_attribute "first_#{name}", :first_item
      alias_attribute "last_#{name}", :last_item
      alias_attribute "ordered_#{names}", :ordered_items
    end

    # Public: Moves an item to a new position by passing the new previous and
    #   the new next items.
    #
    # item - The item to be moved.
    # new_position - The hash that contains the new previous and/or new next
    #   item using the keys :prev_item and :next_item, respectively.
    #
    # Returns true.
    def move(item, new_position = {})
      item.class.transaction do
        previous_item = item.send("previous_#{item.class.name.downcase}")
        next_item = item.send("next_#{item.class.name.downcase}")

        # Update previous position
        next_item.update_attribute(:previous_id, item.previous_id) if next_item

        # Update new position
        new_previous = new_position[:prev_item]
        new_next = new_position[:next_item]
        if new_previous
          item.update_attribute(:previous_id, new_previous.id)
        else
          item.update_attribute(:previous_id, nil)
        end

        new_next.update_attribute(:previous_id, item.id) if new_next
      end
    end
  end
end
