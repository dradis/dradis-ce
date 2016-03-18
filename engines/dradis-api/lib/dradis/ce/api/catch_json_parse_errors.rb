module Dradis::CE::API
  class CatchJsonParseErrors

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue JSON::ParserError => error
        error_output = "There was a problem in the JSON you submitted: #{ error.message }"
        return [ 400, { "Content-Type" => "application/json" },
          [
            {
              message: "Bad request",
              description: error_output
            }.to_json
          ] ]
      end
    end

  end
end
