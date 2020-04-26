shared_examples "a model that has fields" do |model|
  describe "#title" do
    let(:record) { model.new(fields_column => content) }
    subject { record.title }

    context "when there is a #[Title]# field" do
      let(:content) { "#[Title]#\nMy Title" }

      it { should eq "My Title" }

      specify "#title? returns true" do
        expect(record.title?).to be true
      end
    end

    context "when there is no #[Title]# field" do
      let(:content) { "#[Not The Title]#\nMy Title" }
      it { should eq "(No #[Title]# field)" }

      specify "#title? returns false" do
        expect(record.title?).to be false
      end
    end
  end

end
