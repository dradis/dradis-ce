module HeraHelper
  def body_css
    classes = [controller_path.gsub('/', '-'), action_name]
    classes << content_for(:body_class) if content_for?(:body_class)
    classes.compact.join(' ')
  end

  def colored_icon_for_model(model, icon_class, extra_class = nil)
    css =  ['fa-solid']
    css << icon_class
    css << extra_class if extra_class

    options = { class: css.join(' ') }
    tag = nil

    case model
    when Evidence
      tag = model.issue.tags.first
    when Issue
      tag = model.tags.first
    end

    if tag
      options[:style] = "color: #{tag.color}"
    else
      options[:style] = 'color: #222'
    end

    content_tag :i, nil, options
  end

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
    flash.select { |key, _| FlashHelper::ALERT_TYPES.keys.include?(key) }.collect do |name, msg|
      flash_attrs = flash_attrs(msg, name)

      content_tag :div, class: flash_attrs[:flash_css] do
        [
          button_tag(class: 'btn-close', data: flash_attrs[:data_attrs]) do
            '<span class="visually-hidden">Close alert</span>'.html_safe
          end,
          h(msg)
        ].join("\n").html_safe
      end
    end.join("\n").html_safe
  end

  def navbar_brand
    link_to main_app.project_path(current_project), class: 'navbar-brand' do
      image_tag 'logo_small.png', alt: 'Dradis CE logo', class: 'p-lg-0'
    end
  end

  def page_title
    [content_for(:title), 'Dradis Community Edition'].compact.join(' | ')
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end
