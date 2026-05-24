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

  describe '#fields' do
    let(:record) { model.new(fields_column => "#[Title]#\n{{project.name}}") }

    context 'without a Liquid render context' do
      it 'returns raw field values' do
        expect(record.fields['Title']).to eq('{{project.name}}')
      end
    end

    context 'with a Liquid render context' do
      around do |example|
        LiquidRenderContext.set(-> { {} })
        example.run
      ensure
        LiquidRenderContext.clear
      end

      before do
        allow(LiquidRenderContext).to receive(:render) { |v| "rendered:#{v}" }
      end

      it 'renders each field value through the Liquid context' do
        expect(record.fields['Title']).to eq('rendered:{{project.name}}')
      end

      it 'caches the rendered result' do
        expect(record.fields).to be(record.fields)
      end
    end
  end

  describe '#raw_fields' do
    it 'always returns unrendered values regardless of render context' do
      LiquidRenderContext.set(-> { {} })
      record = model.new(fields_column => "#[Title]#\n{{project.name}}")
      expect(record.raw_fields['Title']).to eq('{{project.name}}')
    ensure
      LiquidRenderContext.clear
    end
  end

end
