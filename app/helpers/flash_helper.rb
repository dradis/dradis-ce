module FlashHelper
  # In general controllers use :error, but :alert is used with redirect_to
  # http://guides.rubyonrails.org/action_controller_overview.html#the-flash
  ALERT_TYPES = {
    'alert'               => 'alert-danger',
    'error'               => 'alert-danger',
    'info'                => 'alert-info',
    'notice'              => 'alert-success',
    'warning'             => 'alert-warning',
    'warning_dismissible' => 'alert-warning'
  }

  def flash_attrs(msg, name)
    attrs = {}
    attrs[:flash_css]  = "alert #{ALERT_TYPES.fetch(name)} alert-dismissible"
    attrs[:data_attrs] = { bs_dismiss: 'alert' }
    attrs = flash_attrs_pro(attrs, msg, name) if defined? Dradis::Pro
    attrs
  end

  def flash_attrs_pro(attrs, msg, name)
  end
end
