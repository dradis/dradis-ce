# Monkey-patch RedCloth's HTML Formatter
#
# Context from http://redcloth.org/hobix.com/textile/#writing-in-textile:
# > Single- and double-quotes around words or phrases are converted to curly quotations, much easier on the eye.
#
# Redcloth by default converts quote styles for readability. This changes how
# the quotes get rendered by our textile previews, and our html exporter. The
# problem with that is just consistency. When our users enter a quote they
# expect to get a quote as output. Not a fancy quote. So we're monkey patching
# Redcloth to get the desired results as it's not a configurable option. Our
# Word exporting code has also been adjusted to be consistent with this change.
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
