module HTML
  module CommentsFormatter
    include RedCloth::Formatters::HTML

    def code(opts)
      "@#{opts[:text]}@"
    end
  end
end
