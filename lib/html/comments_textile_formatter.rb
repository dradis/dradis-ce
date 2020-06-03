module HTML
  module CommentsTextileFormatter
    include RedCloth::Formatters::HTML

    def code(opts)
      "@#{opts[:text]}@"
    end
  end
end
