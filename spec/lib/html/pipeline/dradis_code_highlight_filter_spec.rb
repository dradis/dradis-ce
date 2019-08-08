require 'rails_helper'

DradisCodeHighlightFilter = HTML::Pipeline::DradisCodeHighlightFilter

describe DradisCodeHighlightFilter do

  it "detects highlights across multiple lines" do
    source = "<pre><code>- do $${{highlighted}}$$\n- sol fa mi * re do $${{highlighted}}$$ re mi</code></pre>"
    result = "<pre><code>- do <mark>highlighted</mark>\n- sol fa mi * re do <mark>highlighted</mark> re mi</code></pre>"
    doc    = DradisCodeHighlightFilter.call(source, {})

    expect(doc.to_s).to eq(result)
  end

  it "detects two highlights in one line" do
    source = "<pre><code>Tests performed: do $${{highlighted}}$$ re mi fa * sol fa mi * re do $${{highlighted}}$$ re mi</code></pre>"
    result = "<pre><code>Tests performed: do <mark>highlighted</mark> re mi fa * sol fa mi * re do <mark>highlighted</mark> re mi</code></pre>"
    doc    = DradisCodeHighlightFilter.call(source, {})

    expect(doc.to_s).to eq(result)
  end
end
