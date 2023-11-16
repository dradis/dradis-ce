require 'rails_helper'

describe HTML::IgnoreLiquidInLinks do
  it 'wraps the line with liquid "raw" tags' do
    source = 'p.https://hello.world'
    result = "{% raw %}p.https://hello.world{% endraw %}\n"
    expect(described_class.call(source)).to eq(result)
  end

  context "links that contain '{{'" do
    it 'wraps the line with liquid "raw" tags' do
      source = 'p.https://he{{o.world'
      result = "{% raw %}p.https://he{{o.world{% endraw %}\n"
      expect(described_class.call(source)).to eq(result)
    end
  end
end
