module SnowcrashHelper
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
end