class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def markdown(text)
    Redcarpet.new(text, :hard_wrap, :filter_html, :autolink).to_html.html_safe
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end
