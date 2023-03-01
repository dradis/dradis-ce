class Card < ApplicationRecord
  include Commentable
  include HasFields
  include RevisionTracking
  include Subscribable

  dradis_has_fields_for :description

  # -- Relationships --------------------------------------------------------
  belongs_to :list, touch: true
  belongs_to :previous_card,
             foreign_key: :previous_id,
             class_name: 'Card',
             optional: true
  has_and_belongs_to_many :assignees, class_name: 'User'
  has_many :activities, as: :trackable

  delegate :project, to: :list
  delegate :board, to: :list

  # -- Callbacks ------------------------------------------------------------
  after_destroy :add_board_id_to_version
  after_destroy :adjust_link
  after_save :subscribe_new_assignees

  # -- Validations ----------------------------------------------------------
  validates :description, length: { maximum: DB_MAX_TEXT_LENGTH }
  validates :name, presence: true, length: { maximum: DB_MAX_STRING_LENGTH }
  validates :list, presence: true

  # -- Instance Methods -----------------------------------------------------
  def next_card
    self.list.cards.find_by(previous_id: self.id)
  end

  # We are overwriting this method for 2 reasons:
  # 1. Cards and assigness have a hbtm relation, and touch is not supported :(
  # We force here to touch updated_at on the card when changing assignees
  # 2. Due to the hbtm relationship, we cannot use `changed?` to detect new
  # assignees (?). We set a `@new_assignees` instance variable in this method to
  # get that info.
  def assignee_ids=(ids)
    # 1.
    self.touch if self.persisted?
    # 2.
    @new_assignees = ids - (assignee_ids + [''])

    super(ids)
  end

  def to_xml(xml_builder, includes: [], version: 3)
    xml_builder.card do |card_builder|
      card_builder.id(id)
      card_builder.name(name)
      card_builder.description do
        card_builder.cdata!(description)
      end
      card_builder.due_date(due_date)
      card_builder.previous_id(previous_id)

      if includes.include?(:assignees)
        card_builder.assignees do |assignee_builder|
          assignees.each do |assignee|
            assignee_builder.assignee(assignee.email)
          end
        end
      end

      if includes.include?(:activities)
        card_builder.activities do |activity_builder|
          activities.each do |activity|
            activity.to_xml(activity_builder)
          end
        end
      end

      if includes.include?(:comments)
        card_builder.comments do |comment_builder|
          comments.each do |comment|
            comment.to_xml(comment_builder)
          end
        end
      end
    end
  end

  private
  def local_fields
    {
      'List'  => list.name.parameterize(preserve_case: true, separator: '_'),
      'Title' => name
    }
  end

  # We are saving the board_id to the card's version so that if the card's list
  # is deleted, we still have an idea if the card's board still exists.
  def add_board_id_to_version
    version =
      PaperTrail::Version.
        where(item_type: 'Card', item_id: self.id).
        order(id: :desc).
        first

    version.update_attribute(
      :object,
      version.object + "#board_id: #{self.board.id}\n"
    )
  end

  def adjust_link
    if self.next_card
      self.next_card.update_attribute :previous_id, self.previous_id
    end
  end

  def subscribe_new_assignees
    @new_assignees ||= []

    # FIXME: subscribe all of them in a single query
    @new_assignees.each do |user_id|
      Subscription.subscribe(user: User.find(user_id), to: self)
    end

    @new_assignees = []
  end
end
