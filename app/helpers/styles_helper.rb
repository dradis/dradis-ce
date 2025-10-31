module StylesHelper
  require 'redcarpet'
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  class RougeHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  def highlight_code(code, language = :text)
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
    lexer = Rouge::Lexer.find(language)
    if lexer
      # Render the code block with Rouge
      formatter.format(lexer.lex(code))
    else
      # Fallback for unsupported languages
      code
    end
  end
end
