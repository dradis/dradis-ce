module LiquidRenderContext
  def self.clear
    Thread.current[:liquid_render_context] = nil
  end

  def self.current
    Thread.current[:liquid_render_context]&.call
  end

  def self.render(value)
    assigns = current
    return value unless assigns

    HTML::Pipeline::Dradis::LiquidFilter.call(value, liquid_assigns: assigns)
  rescue Liquid::Error
    value
  end

  def self.set(assigns)
    Thread.current[:liquid_render_context] = assigns.respond_to?(:call) ? assigns : -> { assigns }
  end
end
