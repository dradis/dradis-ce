class ErrorsController < ApplicationController
  layout 'errors'

  SUPPORTED_ERRORS = {
    bad_request: 400,
    not_found: 404,
    unsupported_browser: 406,
    unprocessable_entity: 422,
    internal_server_error: 500
  }.freeze

  SUPPORTED_ERRORS.each do |status_name, status_code|
    define_method(status_name) do
      @exception = request.env['action_dispatch.exception']

      respond_to do |format|
        format.html { render "errors/#{status_code}" }
        format.any  { head status_code }
      end
    end
  end
end
