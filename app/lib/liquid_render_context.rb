module LiquidRenderContext
  def self.current
    Thread.current[:liquid_render_context]&.call
  end

  def self.set(assigns_provider)
    Thread.current[:liquid_render_context] = assigns_provider
  end

  def self.clear
    Thread.current[:liquid_render_context] = nil
  end
end
