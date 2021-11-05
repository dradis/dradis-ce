class SetupRequiredController < ApplicationController
  before_action :setup_required

  private
  def setup_required
    if (::Configuration.shared_password == 'improvable_dradis')
      redirect_to new_setup_password_path
    end
  end
end
