shared_examples 'a linked list model' do
  it 'responds to association methods based on list_item_name' do
    expect(model.new).to respond_to(:items, :first_item, :last_item, :ordered_items)
    expect(model.new).to respond_to(
      "first_#{list_item}".to_sym,
      "last_#{list_item}".to_sym,
      "ordered_#{list_item.pluralize}".to_sym
    )
  end
end

# This shared_example tests the move method for linked list items.
# Required instance variables:
#   - parent - the linked list model instance of the item
#   - list_item - the item to be moved
shared_examples 'moving the item' do
  before do
    item_class = @list_item.class.name.downcase.to_sym
    parent_id_sym = "#{@parent.class.name.downcase}_id".to_sym
    @new_previous_item = create(item_class, { parent_id_sym => @parent.id, previous_id: @list_item.id })
    @new_next_item = create(
      item_class,
      { parent_id_sym => @parent.id, previous_id: @new_previous_item.id }
    )
  end

  describe 'when moving an item between two items' do
    it 'successfully moves an item between two items' do
      @parent.move(
        @list_item,
        prev_id: @new_previous_item.id,
        next_id: @new_next_item.id
      )

      expect(@list_item.previous_id).to eq(@new_previous_item.id)
      expect(@new_next_item.reload.previous_id).to eq(@list_item.id)
    end
  end

  describe 'when moving an item as the first item of the list' do
    it 'successfully sets the item as the first item' do
      @parent.move(@new_next_item, next_id: @list_item.id)

      expect(@new_next_item.previous_id).to be_nil
      expect(@list_item.reload.previous_id).to eq(@new_next_item.id)
    end
  end
end
