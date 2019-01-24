require 'rails_helper'

describe ApplicationHelper do
  describe "#markup" do

    it "correctly parses urls containing multiple dots" do
      expect(helper.markup("h1. More test, http://example.org/Some.Nonexisting.URI.with.dots.inside?foobarfoobarfoobar")).to include('<a href="http://example.org/Some.Nonexisting.URI.with.dots.inside?foobarfoobarfoobar">')
    end

    it "correctly parses urls containing parenthesis" do
      expect(helper.markup("test content http://example.org/Some.page(moreinfo) more here")).to include('<a href="http://example.org/Some.page(moreinfo)">')
    end

    it "correctly parses urls containing a combination of capital letters and parenthesis" do
      expect(helper.markup("https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)")).to include('<a href="https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)">')
    end

    it "correctly parses bold tags" do
      expect(helper.markup("The word *duck* should be bold.")).to include("<strong>duck</strong>")
    end

    it 'correctly parses Textile header tags' do
      text = "h1. H1\n\nh2. H2\n\nh3. H3\n\nh4. H4\n\nh5. H5\n\nh6. H6"
      expect(helper.markup(text)).to include '<h1>H1</h1>'
      expect(helper.markup(text)).to include '<h2>H2</h2>'
      expect(helper.markup(text)).to include '<h3>H3</h3>'
      expect(helper.markup(text)).to include '<h4>H4</h4>'
      expect(helper.markup(text)).to include '<h5>H5</h5>'
      expect(helper.markup(text)).to include '<h6>H6</h6>'
    end

    it 'escapes HTML entities' do
      # careful: we want to escape any HTML provided by the user, but the HTML
      # pipeline will add HTML tags of its own (when parsing Textile) which
      # shouldn't be escaped
      text_0 = '<code onmouseover=alert(1);>'
      expect(helper.markup(text_0)).to include '&lt;code onmouseover=alert(1);&gt;'

      text_1 = '<script>alert()</script>'
      expect(helper.markup(text_1)).to include(
        '&lt;script&gt;alert()&lt;/script&gt;'
      )

      text_2 = '*bold* <script> <code>'
      expect(helper.markup(text_2)).to include(
        '<strong>bold</strong> &lt;script&gt; &lt;code&gt;'
      )
    end
  end
end
