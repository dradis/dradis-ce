require 'rails_helper'

describe LiquidRenderContext do
  after { described_class.clear }

  describe '.set and .current' do
    it 'evaluates the stored proc on access' do
      assigns = { 'key' => 'value' }
      described_class.set(-> { assigns })
      expect(described_class.current).to eq(assigns)
    end
  end

  describe '.clear' do
    it 'removes the stored context' do
      described_class.set(-> { {} })
      described_class.clear
      expect(described_class.current).to be_nil
    end
  end

  describe '.render' do
    context 'without a render context' do
      it 'returns the value unchanged' do
        expect(described_class.render('{{project.name}}')).to eq('{{project.name}}')
      end
    end

    context 'with a render context' do
      let(:project) { create(:project, name: 'ACME Corp') }
      let(:assigns) { LiquidCachedAssigns.new(project: project) }

      before { described_class.set(-> { assigns }) }

      it 'renders Liquid templates against the assigns' do
        expect(described_class.render('{{project.name}}')).to eq('ACME Corp')
      end

      it 'returns the raw value when a Liquid::Error is raised' do
        allow(HTML::Pipeline::Dradis::LiquidFilter).to receive(:call).and_raise(Liquid::Error)
        expect(described_class.render('{{invalid}}')).to eq('{{invalid}}')
      end
    end
  end
end
