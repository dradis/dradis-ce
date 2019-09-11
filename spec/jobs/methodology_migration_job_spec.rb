require 'rails_helper'

RSpec.describe MethodologyMigrationJob do
  let(:project) { create(:project) }

  let(:methodology) do
    Methodology.from_file(Rails.root.join(
      'spec/fixtures/files/methodologies/with_checked_tasks.xml')
    )
  end

  let(:board) { Board.where(name: methodology.name).first }

  it 'uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_migrate')
  end

  describe "#perform" do
    before do
      # add methodology to the methodology_library node as a note
      project.methodology_library.notes.create(
        category: Category.default, author: 'rspec', text: methodology.content
      )

      # launch job
      described_class.new.perform(project_id: project.id)
    end

    it "migrates the board" do
      expect(board).not_to be_nil
    end

    it "migrates the lists" do
      expect(board.lists.map(&:name)).to eq ["Pending", "Done"]
      expect(
        board.lists.where(name: "Done").first.previous_id
      ).to eq board.lists.where(name: "Pending").first.id
      expect(
        board.lists.where(name: "Pending").first.cards.count
      ).to eq methodology.tasks.count - methodology.completed_tasks.count
      expect(
        board.lists.where(name: "Done").first.cards.count
      ).to eq methodology.completed_tasks.count
    end

    it "migrates the cards" do
      section = methodology.sections.last
      task    = section.tasks.last
      card    = Card.where(name: "[#{section.name}] #{task.name}").first
      expect(card).not_to be_nil
      expect(card.description).to eq <<-DESCRIPTION.gsub(/^ +/, "")
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
      expect(card.previous_id).not_to be_nil
    end

    it "marks the methodology note as migrated" do
      expect(
        project.methodology_library.reload.properties[:already_migrated]
      ).to eq([project.methodology_library.notes.first.id])
    end
  end
end
