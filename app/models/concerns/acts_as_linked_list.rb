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
    # parent - The item's parent
    # new_position - The hash that contains the new previous and/or new next
    #   item using the keys :prev_item and :next_item, respectively.
    #
    # Returns true when item is moved successfully to the new position.
    # Returns false when the new position is invalid.
    def move(item, parent, new_position = {})
      item.class.transaction do
        previous_item = item.send("previous_#{item.class.name.downcase}")
        next_item = item.send("next_#{item.class.name.downcase}")
        new_previous = new_position[:prev_item]
        new_next = new_position[:next_item]

        # Validates new position
        is_new_position_valid = if new_previous.present?
                                  next_item_of_new_previous = new_previous.send("next_#{new_previous.class.name.downcase}")
                                  if next_item_of_new_previous
                                    new_next == next_item_of_new_previous
                                  else
                                    new_next.nil?
                                  end
                                else
                                  if parent.items.empty?
                                    new_next.nil?
                                  else
                                    if parent.first_item
                                      new_next == parent.first_item
                                    else
                                      new_next.nil?
                                    end
                                  end
                                end
        return false unless is_new_position_valid

        # Update previous position
        next_item.update_attribute(:previous_id, item.previous_id) if next_item

        # Update new position
        new_next.update_attribute(:previous_id, item.id) if new_next

        if new_previous
          item.update_attribute(:previous_id, new_previous.id)
        else
          item.update_attribute(:previous_id, nil)
        end
      end
    end
  end
end
