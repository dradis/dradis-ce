shared_examples 'a model that scrubs invalid encoding' do |attribute|
  it "scrubs invalid byte sequences from #{attribute} before saving" do
    record.public_send("#{attribute}=", "before \xC3\x28 after")

    record.save!

    expect(record.public_send(attribute).valid_encoding?).to eq(true)
    expect(record.reload.public_send(attribute).valid_encoding?).to eq(true)
  end
end
