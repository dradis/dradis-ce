# This controller can be a handy one to inherit from if we are building
# functionality that requires the user to be authenticated.
#
# It isolates the code from the authentication implementation as we will be able
# to change the details of the filter without the inheriting classes noticing.
#
# Any third-party code (e.g. plugins) should inherit from this class instead of
# calling the authentication filters directly
class AuthenticatedController < ApplicationController
  # We are using 'prepend_' here so this is executed before
  # ApplicationController#protect_from_forgery. If not, when the user session
  # expires we see an 'Invalid csrf token' exception for requests that require
  # a csrf token. But it is not a csrf attack, it's just that wo/ session the token
  # cannot be checked.
  prepend_before_action :login_required
  before_action :set_paper_trail_whodunnit
  # before_action :render_onboarding_tour

  # This is a central location where we can manage authorization errors (e.g.
  # alert admins, block accounts, etc.)
  # For the time being just swallow the AccessDenied exception and present it
  # as a not found error
  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to main_app.root_url, :alert => exception.message
    raise ActiveRecord::RecordNotFound.new
  end

  # Set 'whodunnit' in paper trail versions to be the email address of the
  # current user
  def user_for_paper_trail
    current_user.email if current_user
  end

  # This method needs to be available in the views so RevisionsHelper can
  # determine whether a revision was made by the current user.
  helper_method :user_for_paper_trail

  private
  # This filter redirects every request to the first-time onboarding Tour until
  # the user has completed it.
  def render_onboarding_tour
    if TourRegistry.display_for?(:first_sign_in, current_user)
      redirect_to tour_path
    end
  end

end
