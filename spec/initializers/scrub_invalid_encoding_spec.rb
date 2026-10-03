require 'rails_helper'

describe 'scrubbing invalid encoding' do
  let(:bad_bytes) { "before \xC3\x28 after" }

  it 'scrubs invalid byte sequences on cast' do
    type = ActiveModel::Type::String.new

    expect(type.cast(bad_bytes).valid_encoding?).to eq(true)
  end

  it 'leaves valid strings untouched' do
    type = ActiveModel::Type::String.new

    expect(type.cast('valid string')).to eq('valid string')
  end

  it 'passes non-string values through to the wrapped type' do
    type = ActiveModel::Type::String.new

    expect(type.cast(42)).to eq('42')
  end

  it 'covers :string columns' do
    node = build(:node, label: bad_bytes)

    node.save!

    expect(node.reload.label.valid_encoding?).to eq(true)
  end

  it 'covers :text columns' do
    note = build(:note, text: bad_bytes)

    note.save!

    expect(note.reload.text.valid_encoding?).to eq(true)
  end

  it 'covers :string columns without per-model opt-in' do
    card = create(:card, name: bad_bytes)

    expect(card.reload.name.valid_encoding?).to eq(true)
  end
end
