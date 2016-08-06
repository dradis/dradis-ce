module NodesHelper # :nodoc:
  def short_filename(long_filename)
    # hyphens are word-wrapped by the browser
    return long_filename if long_filename =~ /\-/

    return truncate(long_filename, length: 20)
  end
end
