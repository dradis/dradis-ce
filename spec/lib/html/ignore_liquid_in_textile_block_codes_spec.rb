require 'rails_helper'

describe HTML::IgnoreLiquidInTextileBlockCodes do
  describe 'bc. block code' do
    context 'single line' do
      it 'wraps the line with liquid "raw" tags' do
        source = 'bc. single line single paragraph block code'
        result = "{% raw %}bc. single line single paragraph block code{% endraw %}\n"
        expect(described_class.call(source)).to eq(result)
      end
    end

    context 'multi line' do
      it 'wraps each line with liquid "raw" tags' do
        source = "bc. multi line\r\nsingle paragraph block code"
        result = "{% raw %}bc. multi line{% endraw %}\n{% raw %}single paragraph block code{% endraw %}\n"
        expect(described_class.call(source)).to eq(result)
      end
    end

    context 'with blank line after single paragraph block code' do
      it 'does not wrap lines after the blank line with liquid "raw" tags' do
        source = "bc. multi line \r\nsingle paragraph block code\r\n\r\n#[Title]#\r\nHello"
        result = described_class.call(source).to_s
        expect(result.lines.select { |line| line.include?('{% raw %}') }.size).to eq(2)
      end
    end
  end

  describe 'bc.. block code' do
    it 'wraps each line with liquid "raw" tags' do
      source = "bc.. multi paragraph\r\nblock code\r\nstill in the block code"
      result = "{% raw %}bc.. multi paragraph{% endraw %}\n{% raw %}block code{% endraw %}\n{% raw %}still in the block code{% endraw %}\n"
      expect(described_class.call(source)).to eq(result)
    end

    ['bq. ', 'bq.. ', 'h5. ', 'p. '].each do |block_paragraph_type|
      context "with blank line and \"#{block_paragraph_type}\" after multi paragraph block code" do
        it "does not wrap lines after \"#{block_paragraph_type}\" with liquid 'raw' tags" do
          source = "bc.. multi paragraph\r\nblock code\r\n\r\nstill in the block code\r\n\r\n#{block_paragraph_type}line 1\r\nline 2"
          result = described_class.call(source)
          expect(result.lines.select { |line| line.include?('{% raw %}') }.size).to eq(4)
        end
      end
    end

    context 'with blank line and a Field after multi paragraph block code' do
      it "does not wrap lines after the Field with liquid 'raw' tags" do
        source = "bc.. multi paragraph\r\nblock code\r\n\r\nstill in the block code\r\n\r\n#[Title]#\r\nline 1\r\nline 2"
        result = described_class.call(source)
        expect(result.lines.select { |line| line.include?('{% raw %}') }.size).to eq(4)
      end
    end
  end

  describe 'URLs with unclosed Liquid' do
    it 'wraps the URL of a Textile link with liquid "raw" tags' do
      source = "\"Link text\":https://te{{t.com\n"
      result = "\"Link text\":{% raw %}https://te{{t.com{% endraw %}\n"
      expect(described_class.call(source)).to eq(result)
    end

    it 'wraps a bare URL with liquid "raw" tags' do
      source = "p. https://hello.world/hereit{%is now\n"
      result = "p. {% raw %}https://hello.world/hereit{%is{% endraw %} now\n"
      expect(described_class.call(source)).to eq(result)
    end

    it 'does not wrap a URL with closed Liquid on the same line' do
      source = "https://example.com/{{ issue.title }}\n"
      expect(described_class.call(source)).to eq(source)
    end

    it 'does not nest "raw" tags for URLs inside block codes' do
      source = "bc. https://te{{t.com\nhttps://hello{{world"
      result = "{% raw %}bc. https://te{{t.com{% endraw %}\n{% raw %}https://hello{{world{% endraw %}\n"
      expect(described_class.call(source)).to eq(result)
    end
  end
end
