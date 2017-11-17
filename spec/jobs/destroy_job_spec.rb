require 'rails_helper'

describe MultiDestroyJob do #, type: :job do

  it 'is uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end

  describe '#perform' do
    before do
      node = create(:node)
      @notes = [
        create(:note, node: node),
        create(:note, node: node),
        create(:note, node: node),
      ]

      described_class.new.perform(
        items: @notes,
        author_email: 'rspec@dradisframework.com',
        uid: 1
      )
    end

    it 'deletes the items' do
      expect(Note.where(id: @notes.map(&:id))).to be_empty
    end

    it 'writes a known final line in the log' do
      expect(Log.last.text).to eq 'Worker process completed.'
    end
  end
end
