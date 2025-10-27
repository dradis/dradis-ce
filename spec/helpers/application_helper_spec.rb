require 'rails_helper'

describe ApplicationHelper do
  describe '#markup' do

    it 'correctly parses urls containing multiple dots' do
      expect(helper.markup('h1. More test, http://example.org/Some.Nonexisting.URI.with.dots.inside?foobarfoobarfoobar')).to include('<a href="http://example.org/Some.Nonexisting.URI.with.dots.inside?foobarfoobarfoobar">')
    end

    it 'correctly parses urls containing parenthesis' do
      expect(helper.markup('test content http://example.org/Some.page(moreinfo) more here')).to include('<a href="http://example.org/Some.page(moreinfo)">')
    end

    it 'correctly parses urls containing a combination of capital letters and parenthesis' do
      expect(helper.markup('https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)')).to include('<a href="https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)">')
    end

    it 'correctly parses bold tags' do
      expect(helper.markup('The word *duck* should be bold.')).to include('<strong>duck</strong>')
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
      # careful: we are allowing code tags to be correctly parsed as html, but
      # we are sanitizing attributes that might be considered as unsafe.
      text_0 = '<code onmouseover=alert(1);>'
      expect(helper.markup(text_0)).to include '<div><p><code></code></p></div>'

      text_1 = '<script>alert()</script>'
      expect(helper.markup(text_1)).to include(
        '<div>&lt;script&gt;alert()&lt;/script&gt;</div>'
      )

      text_2 = '*bold* <script> <code>'
      expect(helper.markup(text_2)).to include(
        '<div><p><strong>bold</strong> &lt;script&gt; <code></code></p></div>'
      )

      text_3 = "xssbc. <script>alert(1)</script>\n\n"\
        'xssbc.. <script>alert(1)</script>'
      expect(helper.markup(text_3)).to include(
        "<div>\n<p>xssbc. &lt;script&gt;alert(1)&lt;/script&gt;</p>\n"\
        "<p>xssbc.. &lt;script&gt;alert(1)&lt;/script&gt;</p>\n</div>"
      )

      text_4 =
        "bc.. block code\n\n" \
        "h1. <script>alert(1)</script>\n\n" \
        "bq. <script>alert(2)</script>\n\n" \
        "div. <script>alert(3)</script>\n\n" \
        "p(xss). <script>alert(4)</script>\n\n" \
        "p(#xss). <script>alert(5)</script>\n\n" \
        "p(xss#xss). <script>alert(6)</script>\n\n" \
        "p[xss]. <script>alert(7)</script>\n\n" \
        "p<. <script>alert(8)</script>\n\n" \
        "p(. <script>alert(9)</script>\n\n"

      expect(helper.markup(text_4)).to include(
        "<div>\n<pre><code>block code</code></pre>\n"\
        "<h1>&lt;script&gt;alert(1)&lt;/script&gt;</h1>\n"\
        "<blockquote>\n<p>&lt;script&gt;alert(2)&lt;/script&gt;</p>\n</blockquote>\n"\
        "<div>&lt;script&gt;alert(3)&lt;/script&gt;</div>\n"\
        "<p class=\"xss\">&lt;script&gt;alert(4)&lt;/script&gt;</p>\n"\
        "<p id=\"xss\">&lt;script&gt;alert(5)&lt;/script&gt;</p>\n"\
        "<p class=\"xss\" id=\"xss\">&lt;script&gt;alert(6)&lt;/script&gt;</p>\n"\
        "<p lang=\"xss\">&lt;script&gt;alert(7)&lt;/script&gt;</p>\n"\
        "<p style=\"text-align:left;\">&lt;script&gt;alert(8)&lt;/script&gt;</p>\n"\
        "<p style=\"padding-left:1em;\">&lt;script&gt;alert(9)&lt;/script&gt;</p>\n"
      )

      text_5 = '“xss”:http://<script>alert(1)</script>;'
      expect(helper.markup(text_5)).to include(
        '<div><p>“xss”:http://&lt;script&gt;alert(1)&lt;/script&gt;;</p></div>'
      )
    end
  end
end
