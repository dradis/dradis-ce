class Board < ApplicationRecord
  include ActsAsLinkedList
  list_item_name :list

  # -- Relationships --------------------------------------------------------
  belongs_to :node
  has_many :activities, as: :trackable
  # NOTE: Rails >= 5.1 raises error when a `has_many :y, through: x`
  # relationship is defined before the corresponding `has_many :x` relationship.
  # (https://github.com/rails/rails/pull/27485).
  # So we define `lists` before `cards`
  has_many :lists, dependent: :destroy
  has_many :cards, through: :lists

  def project
    # dummy project; this makes Boards's interface more similar to how it is
    # in Pro and makes it easier to deal with board in URL helpers
    @project ||= Project.new
  end

  def project=(new_project); end

  # -- Callbacks ------------------------------------------------------------
  after_save :set_default_node

  # -- Validations ----------------------------------------------------------
  validates :name, presence: true, length: { maximum: DB_MAX_STRING_LENGTH }
  validates :project, presence: true
  validate  :validate_node_has_no_other_board

  # -- Scopes -----------------------------------------------------------------

  # -- Class Methods ----------------------------------------------------------

  # -- Instance Methods -------------------------------------------------------
  def recovered_list
    list = self.lists.find_by(name: 'Recovered')
    if !list
      list = self.lists.new(name: 'Recovered')
      list.previous_id = self.last_list.try(:id)
      list.save
    end

    list
  end

  private

  def set_default_node
    self.node = Project.find(1).methodology_library
  end

  def validate_node_has_no_other_board
    if self.node.try(:type_id) != Node::Types::METHODOLOGY \
    && Board.where.not(id: self.id).where(node_id: self.node_id).any?
      errors.add(:node, 'already has a board')
    end
  end
end
