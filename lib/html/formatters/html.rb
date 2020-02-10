# Monkey-patch RedCloth's HTML Formatter
module RedCloth::Formatters::HTML

  # Override quote1 method to use apostrophe
  def quote1(opts)
    "&apos;#{opts[:text]}&apos;"
  end

  # Override quote2 method to use straight double quotes
  def quote2(opts)
    "&quot;#{opts[:text]}&quot;"
  end

end
