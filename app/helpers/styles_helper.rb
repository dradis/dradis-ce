module StylesHelper
  require 'rouge'

  def highlight_code(code, language = 'html')
    lexer = Rouge::Lexer.find(language)
    formatter = Rouge::Formatters::HTML.new
    "<pre class='highlight'>#{formatter.format(lexer.lex(code))}</pre>"
  end
end
