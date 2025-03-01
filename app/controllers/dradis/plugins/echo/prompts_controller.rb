require 'ollama-ai'

module Dradis::Plugins::Echo
  class PromptsController < AuthenticatedController
    include ProjectScoped

    before_action :set_client

    def show
      prompt =<<~EOP
      I am a cyber security professional working an a cybersecurity assessment.

      I found a vulnerability and I'd like for you to help me craft a
      description and recommendation that's going to make it easy to understand
      for the owners of the system I'm testing.

      So far, this is what I've got, please give me your suggestions.
      EOP

      %w{Title Description Solution}.each do |field|
        prompt << "#{field}: #{Issue.find(params[:id]).fields[field]}\n\n"
      end

      result = @client.generate(
        {
          model: Engine.settings.model,
          prompt: prompt,
          stream: false
        }
      )
      render html: ('<pre>%s</pre>' % result.first['response']).html_safe
    end

    def set_client
      @client = Ollama.new(
        credentials: { address: Engine.settings.address },
        options: { server_sent_events: true }
      )
    end
  end
end
