module HTML
  module NoInlineCodeTextileFormatter
    include RedCloth::Formatters::HTML

    def code(opts)
      if opts[:block]
        super(opts)
      else
        "@#{opts[:text]}@"
      end
    end
  end
end
