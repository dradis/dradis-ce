module Dradis::CE::API
  class APIController < ApplicationController
    # force_ssl if: :ssl_configured?

    before_action :api_authentication_required
    before_action :json_required, only: [:create, :update]

    # FIXME: do we need this?
    # load_and_authorize_resource except: [:new, :edit, :access_denied]

    after_action :skip_set_cookies_header

    # FIXME: do we need this?
    # Swallow the AccessDenied exception and present it as a 403 Forbidden error
    # rescue_from CanCan::AccessDenied do |exception|
    #   render json: {
    #     message: "Forbidden",
    #     description: "The authenticated user does not have access to this operation"
    #   }, status: 403
    # end

    def destroy
      resource.destroy
      respond_to do |format|
        format.json do
          render json: {
            message: "Resource deleted successfully"
          }, status: 200
        end
      end
    end

    protected
    # def ssl_configured?
    #   !Rails.env.development?
    # end

    def api_authentication_required
      warden.authenticate!(:api_auth)
    end

    # Pretty-print JSON output
    def render(params = {})
      return super(params) unless request.format.symbol == :json
      json_string = render_to_string params
      json_object = JSON.parse json_string
      pretty_json = JSON.pretty_generate json_object
      params.merge! json: pretty_json
      super params
    end

    # Require Content-Type set to application/json for POST and PUT operations
    def json_required
      unless request.content_type == 'application/json'
        render json: {
          message: "JSON required",
          description: "A Content-Type header set to 'application/json' must be sent for this request"
        }, status: 415
      end
    end

    # ---------------------------------------------------------- Authentication
    # In API controllers, render 401 and a JSON body instead of the default
    # defined in ApplicationController.
    #
    # This action is used as Warden's :failure_app (see engine.rb)
    def access_denied
      render json: {
        message: "Authentication required",
        description: "No authentication credentials have been provided.
          Please use one of the supported authentication methods (token or basic authentication)"
      }, status: 401
    end

    # ----------------------------------------------------------- Avoid cookies
    # In API controllers, we don't need to set any cookies (i.e. remove
    # Set-Cookie headers).
    def skip_set_cookies_header
      request.session_options[:skip] = true
    end

    # ------------------------------------------------------- Validation errors
    def resource
      instance_variable_get("@#{ resource_name }")
    end

    def resource_name
      controller_name.singularize
    end

    def render_validation_error
      render json: {
        message: "Validation error",
        description: "Some validation errors were found and the #{ resource_name } couldn't be saved",
        errors: resource.errors
      }, status: 422
    end
  end
end
