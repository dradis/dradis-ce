class SetupRequiredController < ApplicationController
  before_action :setup_required

  private
  def setup_required
    defined?(Dradis::Pro) ? setup_required_pro : setup_required_ce
  end

  # -- CE methods -------------------------------------------------------------
  def setup_required_ce
    if (::Configuration.shared_password == 'improvable_dradis')
      redirect_to new_setup_password_path
    end
  end

  # -- Pro methods ------------------------------------------------------------
  def setup_required_pro
  end
end
