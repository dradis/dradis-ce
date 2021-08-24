require 'rails_helper'

describe 'RedCloth Monkey Patch' do
  it 'Does not convert double quotes to double curly quotes' do
    source = '"I find your lack of faith disturbing"'
    result = RedCloth.new(source).to_html

    expect(result).to eq('<p>&quot;I find your lack of faith disturbing&quot;</p>')
  end

  it 'Does not convert single quotes to single curly quotes' do
    source = "'I find your lack of faith disturbing'"
    result = RedCloth.new(source).to_html

    expect(result).to eq('<p>&apos;I find your lack of faith disturbing&apos;</p>')
  end

  context 'in block code' do
    context 'single line' do
      it 'Does not convert double quotes to double curly quotes' do
        source = "bc. ESSID:\"CCC's Customer WiFi\""
        result = RedCloth.new(source).to_html

        expect(result).to eq("<pre><code>ESSID:\"CCC's Customer WiFi\"</code></pre>")
      end

      it 'Does not convert single quotes to single curly quotes' do
        source = "bc. ESSID:'CCC\"s Customer WiFi'"
        result = RedCloth.new(source).to_html

        expect(result).to eq("<pre><code>ESSID:'CCC\"s Customer WiFi'</code></pre>")
      end
    end

    context 'multiline' do
      it 'Does not convert double quotes to double curly quotes' do
        source = "bc.. ESSID:\"CCC's Customer WiFi\""
        result = RedCloth.new(source).to_html

        expect(result).to eq("<pre><code>ESSID:\"CCC's Customer WiFi\"</code></pre>")
      end

      it 'Does not convert single quotes to single curly quotes' do
        source = "bc.. ESSID:'CCC\"s Customer WiFi'"
        result = RedCloth.new(source).to_html

        expect(result).to eq("<pre><code>ESSID:'CCC\"s Customer WiFi'</code></pre>")
      end
    end
  end
end
