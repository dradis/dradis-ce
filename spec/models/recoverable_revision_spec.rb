require 'rails_helper'

describe RecoverableRevision do

  describe ".find" do
    it "returns a RecoverableRevision that wraps the PaperTrail::Version with the given ID" do
      deleted_evidence = create(:evidence)
      deleted_evidence.destroy
      destroy_revision = deleted_evidence.versions.last
      r_revision = RecoverableRevision.find(id:destroy_revision)
      expect(r_revision).to be_a RecoverableRevision
      expect(r_revision.version).to eq destroy_revision
    end

    it "returns an error if the version type is not 'destroy'" do
      evidence        = create(:evidence)
      create_revision = evidence.versions.first
      expect do
        RecoverableRevision.find(id: create_revision.id)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#recover" do
    it "recovers the deleted item and returns true" do
      deleted_evidence = create(:evidence)
      deleted_evidence.destroy
      revision = RecoverableRevision.new(deleted_evidence.versions.last)
      expect(Evidence.exists?(deleted_evidence.id)).to be false
      expect(revision.recover).to be true
      expect(Evidence.exists?(deleted_evidence.id)).to be true
      recovered_evidence = revision.object
      expect(recovered_evidence.content).to eq deleted_evidence.content
    end

    describe "recovering an Evidence whose Issue has been deleted" do
      it "recovers the Issue as well" do
        evidence = create(:evidence)
        issue    = evidence.issue

        evidence.destroy
        issue.destroy

        revision = RecoverableRevision.new(evidence.versions.last)
        expect(Evidence.exists?(evidence.id)).to be false
        expect(Issue.exists?(issue.id)).to be false
        expect(revision.recover).to be true
        expect(Evidence.exists?(evidence.id)).to be true
        expect(Issue.exists?(issue.id)).to be true

        recovered_evidence = revision.object
        expect(recovered_evidence.issue).to eq issue
      end
    end
  end

  describe ".all" do
    before do
      @evidence = create(:evidence)
      @note     = create(:note)
      @issue    = create(:issue)

      @deleted_evidence = create(:evidence)
      @deleted_note     = create(:note)
      @deleted_issue    = create(:issue)

      # More issue/note hackery :(
      # FIXME - ISSUE/NOTE INHERITANCE
      @deleted_issue_as_note = Note.find(@deleted_issue.id)

      [@deleted_note, @deleted_evidence, @deleted_issue].each(&:destroy)
    end

    it "lists only deleted nodes/notes/evidence" do
      expect(described_class.all.map { |v| v.version.reify }).to match_array(
        [@deleted_note, @deleted_evidence, @deleted_issue_as_note]
      )
    end

    it "doesn't return revisions when the item has been recovered" do
      recoverable = described_class.find(id: @deleted_note.versions.last.id)
      recoverable.recover

      expect(described_class.all.map { |v| v.version.reify }).to match_array(
        [@deleted_evidence, @deleted_issue_as_note]
      )
    end

    describe "for items which have been recovered and deleted multiple times" do
      before do
        (3..0).each do |i|
          recoverable = described_class.find(@deleted_note.versions.last.id)
          recoverable.recover
          recoverable.object.destroy
        end
        @result = described_class.all.map { |v| v.version.reify }
      end

      it "only returns one revision per item" do
        expect(@result).to match_array(
          [@deleted_note, @deleted_evidence, @deleted_issue_as_note]
        )
      end

      it "wraps the most recent 'destroy' revision for each item" do
        recoverable_objects = @result.map(&:version)

        destroy_versions = [
          @deleted_note, @deleted_evidence, @deleted_issue_as_note
        ].map { |obj| obj.versions.last }

        expect(recoverable_objects).to match_array(destroy_versions)
      end
    end

  end
end
