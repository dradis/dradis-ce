module Dradis::CE::API
  class CatchJsonParseErrors

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue ActionDispatch::ParamsParser::ParseError => error
        # As of Rails 4, ActionDispatch::ShowExceptions (the next middleware
        # in the stack after this one) will raise the above ParseError when
        # it can't parse the JSON.
        #
        # Note that this is undocumented behavior, which means that this error
        # handler could break without warning in future versions of Rails:
        return [ 400, { "Content-Type" => "application/json" },
          [
            {
              message:     "Bad request",
              description: "There was a problem in the JSON you "\
                           "submitted: #{error.message}"
            }.to_json
          ] ]
      end
    end

  end
end
