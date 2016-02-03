# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  def new
    flash.now[:alert] = warden_message if warden_message.present?
  end

  def create
    warden.authenticate!
    redirect_to_target_or_default root_url
  end

  def destroy
    logout
    redirect_to login_path, notice: 'You have been logged out.'
  end
end
