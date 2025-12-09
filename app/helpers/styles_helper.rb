module StylesHelper
  def highlight_code(code, language = 'html')
    decoded_code = CGI.unescapeHTML(code)
    lexer = Rouge::Lexer.find(language)
    formatter = Rouge::Formatters::HTML.new
    "<pre class='style-code'>#{formatter.format(lexer.lex(decoded_code))}</pre>"
  end
end
