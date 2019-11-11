module TyliumHelper
  def css_class_for_node(node)
    classes = []
    classes << 'hasSubmenu' if node.children_count > 0
    classes << 'active' if node == @node
    classes << 'in' if @node && @node.parent_id == node.id
    classes.join(' ')
  end

  def css_class_for_sub_nodes(node)
    controller_name == 'nodes' && @node && (@node.parent_id == node.id || @node.id == node.id) ? 'in' : ''
  end

  def flash_messages
    # In general controllers use :error, but :alert is used with redirect_to
    #   http://guides.rubyonrails.org/action_controller_overview.html#the-flash
    alert_types = {
      'alert'   => 'alert-error',
      'error'   => 'alert-error',
      'info'    => 'alert-info',
      'notice'  => 'alert-success',
      'warning' => 'alert-warning'
    }

    flash.select { |key, _| alert_types.keys.include?(key) }.collect do |name, msg|
      flash_css = "alert #{alert_types.fetch(name)}"

      content_tag :div, class: flash_css do
        [
          link_to('javascript:void(0)', class: 'close', data: { dismiss: 'alert' }) do 
            '<i class="fa fa-close"></i>'.html_safe
          end,
          h(msg)
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


  def colored_icon_for_model(model, icon_class, extra_class = nil)

    css =  ['fa']
    css << icon_class
    css << extra_class if extra_class

    options = { class: css.join(' ') }
    tag     = nil

    case model
    when Evidence
      tag = model.issue.tags.first
    when Issue
      tag = model.tags.first
    end

    if tag
      options[:style] = "color: #{tag.color}"
    end

    content_tag :i, nil, options
  end
end
