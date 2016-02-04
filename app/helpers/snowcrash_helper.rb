module SnowcrashHelper
  def css_class_for_node(node)
    classes = []
    # Avoid the extra .children call to save a DB query. Defer to ajax-loading to find out.
    classes << 'hasSubmenu' #if node.children.any?
    classes << 'active' if node == @node
    classes << 'in' if @node && @node.parent_id == node.id
    classes.join(' ')
  end

  def css_class_for_sub_nodes(node)
    controller_name == 'nodes' && @node && (@node.parent_id == node.id || @node.id == node.id) ? 'in' : ''
  end

  def flash_messages
    flash.collect do |name, msg|
      flash_css = 'alert'

      # In general controllers use :error, but :alert is used with redirect_to
      #   http://guides.rubyonrails.org/action_controller_overview.html#the-flash
      flash_css << {
        'alert'   => ' alert-error',
        'error'   => ' alert-error',
        'info'    => ' alert-info',
        'notice'  => ' alert-success',
        'warning' => ''
      }[name]

      content_tag :div, class: flash_css do
        [
          link_to('x', 'javascript:void(0)', class: 'close', data: { dismiss: 'alert' }),
          msg
        ].join("\n").html_safe
      end
    end.join("\n").html_safe
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end