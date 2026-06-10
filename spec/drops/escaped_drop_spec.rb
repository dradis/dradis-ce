require 'rails_helper'

describe 'Escaping string from Drops' do
  describe BaseDrop do
    class TestDrop < BaseDrop
      delegate :title, to: :@record
    end

    context 'with XSS content' do
      let(:issue) { create(:issue, text: "#[Title]#\n<script>test output</script>\n") }

      it 'strips script tags' do
        drop = TestDrop.new(issue)
        expect(drop.title).to eq('')
      end
    end

    context 'with Liquid comparison operators (spaces around operator)' do
      let(:issue) { create(:issue, text: "#[Title]#\n{% if a > b %}yes{% endif %}\n") }

      it 'preserves the Liquid tags intact' do
        drop = TestDrop.new(issue)
        expect(drop.title).to eq('{% if a > b %}yes{% endif %}')
      end
    end

    context 'with Liquid comparison operators (no spaces around operator)' do
      let(:issue) { create(:issue, text: "#[Title]#\n{% if cvss<7.0 %}Low{% endif %}\n") }

      it 'preserves the Liquid tags intact' do
        drop = TestDrop.new(issue)
        expect(drop.title).to eq('{% if cvss<7.0 %}Low{% endif %}')
      end
    end

    context 'with Liquid assignment tags' do
      let(:issue) { create(:issue, text: "#[Title]#\n{% assign label = \"critical\" %}\n") }

      it 'preserves the Liquid tags intact' do
        drop = TestDrop.new(issue)
        expect(drop.title).to eq('{% assign label = "critical" %}')
      end
    end

    context 'with mixed Liquid tags and XSS content' do
      let(:issue) { create(:issue, text: "#[Title]#\n{% if x < 10 %}<script>xss</script>{% endif %}\n") }

      it 'preserves Liquid tags and strips XSS content outside them' do
        drop = TestDrop.new(issue)
        expect(drop.title).to eq('{% if x < 10 %}{% endif %}')
      end
    end
  end

  describe EscapedFields do
    class TestDrop < BaseDrop
      include EscapedFields
    end

    context 'with XSS content' do
      let(:issue) { create(:issue, text: "#[Title]#\n<script>test output</script>\n") }

      it 'strips script tags from field values' do
        drop = TestDrop.new(issue)
        expect(drop.fields['Title']).to eq('')
      end
    end

    context 'with Liquid comparison operators (no spaces around operator)' do
      let(:issue) { create(:issue, text: "#[Title]#\n{% if cvss<7.0 %}Low{% endif %}\n") }

      it 'preserves Liquid tags in field values' do
        drop = TestDrop.new(issue)
        expect(drop.fields['Title']).to eq('{% if cvss<7.0 %}Low{% endif %}')
      end
    end
  end
end
