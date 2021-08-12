class List < ApplicationRecord
  include ActsAsLinkedList
  list_item_name :card

  # -- Relationships --------------------------------------------------------
  belongs_to :board, touch: true
  belongs_to :previous_list,
             foreign_key: :previous_id,
             class_name: 'List',
             optional: true
  delegate :project, to: :board
  has_many :activities, as: :trackable
  has_many :cards, dependent: :destroy

  # -- Callbacks ------------------------------------------------------------
  after_destroy :adjust_link

  # -- Validations ----------------------------------------------------------
  validates :board, presence: true
  validates :name, presence: true, length: { maximum: DB_MAX_STRING_LENGTH }

  # -- Scopes -----------------------------------------------------------------

  # -- Class Methods ----------------------------------------------------------

  # -- Instance Methods -----------------------------------------------------
  def next_list
    board.lists.find_by(previous_id: id)
  end

  def to_xml(xml_builder, includes: [], version: 3)
    xml_builder.list do |list_builder|
      list_builder.id(id)
      list_builder.name(name)
      list_builder.previous_id(previous_id)

      ordered_items.each do |card|
        card.to_xml(list_builder, includes: includes)
      end
    end
  end

  private
  def adjust_link
    next_list.update_attribute :previous_id, previous_id if next_list
  end
end
