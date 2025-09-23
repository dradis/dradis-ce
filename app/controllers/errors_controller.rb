class ErrorsController < ApplicationController
  layout 'errors'

  SUPPORTED_STATUS_CODES = [400, 404, 406, 422, 500].freeze

  def show
    @error = request.env['action_dispatch.exception']
    @status_code = determine_status_code

    respond_to do |format|
      format.html { render "errors/#{@status_code}", status: @status_code }
      format.any { head @status_code }
    end
  end

  private

  def determine_status_code
    status_from_params = params[:status_code]&.to_i
    return status_from_params if SUPPORTED_STATUS_CODES.include?(status_from_params)

    if @error
      status_from_exception = @error.try(:status_code) ||
        ActionDispatch::ExceptionWrapper.new(request.env, @error).status_code
      return status_from_exception if SUPPORTED_STATUS_CODES.include?(status_from_exception)
    end

    500
  end
end
