class MethodologyMigrationService
  attr_reader :project

  def initialize(project_id)
    @project = Project.find(project_id)
  end

  def migrate(methodology, board_name: nil, node: nil)
    ActiveRecord::Base.transaction do
      # create a board for each methodology
      board = Board.new(
        name: methodology.name,
        node: node || project.methodology_library,
        project: @project
      )

      # create 2 lists in each board: Pending and Done
      pending, done = ["Pending", "Done"].map do |name|
        board.lists.build(name: name)
      end
      pending.cards, done.cards = extract_cards(methodology)

      board.name = board_name unless board_name.blank?

      board.save!

      # set list order
      done.previous_id = pending.id
      done.save!

      # set card order on every list
      [done, pending].each do |list|
        finalize_list(list)
      end
    end
  end

  def migration_needed?
    methodologylib       = project.methodology_library
    already_migrated_ids = methodologylib.properties[:already_migrated] || []
    migration_needed     = methodologylib.notes.count > already_migrated_ids.count

    return migration_needed &&
           methodologylib.properties[:migration_job_id].nil?
  end

  private

  # Private: extract cards from the methodology xml
  #
  # methodology - a Methodology instance
  #
  # Returns 2 arrays, one of "pending" cards (not checked)
  # and one of "done" cards (checked).
  def extract_cards(methodology)
    pending = []
    done    = []
    methodology.sections.each do |section|
      section.tasks.each do |task|
        # create a card for each task on the methodology
        card = Card.new
        card.name = "[#{section.name}] #{task.name}".truncate(Card.columns_hash['name'].limit || 255)
        card.description = <<-DESCRIPTION.gsub(/^ +/, "")
        This card was automatically created by importing the data from the old methodologies section, these were the values on **#{Time.now.strftime("%d %b %Y")}**:

        #[OriginalMethodology]#
        #{methodology.name}

        #[OriginalSection]#
        #{section.name}

        #[OriginalTask]#
        #{task.name}

        #[OriginalStatus]#
        #{task.checked? ? "done" : "pending"}
        DESCRIPTION

        # add the card to a list depending on its status
        if task.checked?
          done << card
        else
          pending << card
        end
      end
    end
    [pending, done]
  end

  # Private: set card order on the list
  #
  # list - the list to be ordered
  #
  # Returns nothing.
  def finalize_list(list)
    previous_id = nil
    list.cards.each do |card|
      card.previous_id = previous_id
      previous_id = card.id
      card.save!
    end
  end
end
