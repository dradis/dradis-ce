module Dradis::CE::API
  class ExceptionsController < ActionController::Base

    def show
      render json: {
        message:     status_name,
        description: error_message
      }.to_json, status: status_code
    end

    protected

    def status_code
      (request.path.match(/\d{3}/) || ['500'])[0].to_i
    end

    def status_name
      Rack::Utils::HTTP_STATUS_CODES.fetch(status_code, "Internal Server Error")
    end

    def error_message
      if exception
        exception.message
      else
        "Our administrator has been notified about this event."
      end
    end

    def exception
      env['action_dispatch.exception']
    end

  end
end
