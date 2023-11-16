require 'rails_helper'

describe HTML::IgnoreLiquid do
  describe 'bc. block code' do
    it 'ignores liquid in both block code and links' do
      source = "bc. single line single paragraph block code\r\n\r\np.https://hello.world"
      result = described_class.call(source).to_s
      expect(result.lines.select { |line| line.include?('{% raw %}') }.size).to eq(2)
    end
  end

  describe 'bc.. block code' do
    it 'ignores liquid in both block code and links' do
      source = "bc.. multi paragraph\r\nblock code\r\nstill in the block code\r\np.https://hello.world"
      result = described_class.call(source).to_s
      expect(result.lines.select { |line| line.include?('{% raw %}') }.size).to eq(4)
    end
  end
end
