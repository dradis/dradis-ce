require 'rails_helper'

describe HTML::Pipeline::DradisEscapeHTMLFilter do

  describe '#call' do
    it 'should correctly filter the html' do
      str = '<script>alert(1);</script>'
      filtered_str = '&lt;script&gt;alert(1);&lt;/script&gt;'
      expect(described_class.call(str)).to eq(filtered_str)
    end

    context 'string with bc.' do
      it 'should correctly filter the string' do
        str = "bc. <script>alert(1);</script>\n\n"
        expect(described_class.call(str)).to eq(str)
      end
    end

    context 'string with bc..' do
      it 'should correctly filter the string' do
        str = "bc.. <script>alert(1);</script>\n\n"
        expect(described_class.call(str)).to eq(str)
      end
    end

    context 'string with link' do
      it 'should correctly filter the string' do
        str = '"sample link":https://drad.is'
        expect(described_class.call(str)).to eq(str)
      end
    end
  end

end
