require 'rails_helper'

describe ActsAsLinkedList do
  subject { dummy_class.new }

  let(:dummy_class) do
    Class.new {
      include ActsAsLinkedList
      list_item_name :element
    }
  end

  it { should respond_to(:items, :first_item, :last_item, :ordered_items) }
  it { should respond_to(:first_element, :last_element, :ordered_elements) }
end
