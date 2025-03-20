module Dradis::Plugins::Echo
  class EchoJob < ApplicationJob
    queue_as :default

    def perform(prompt_id, issue_id, interaction_id)
      sleep 2

      prompt =<<~EOP
      I am a cyber security professional working an a cybersecurity assessment.

      I found a vulnerability and I'd like for you to help me craft a
      description and recommendation that's going to make it easy to understand
      for the owners of the system I'm testing.

      So far, this is what I've got, please give me your suggestions.
      EOP

      %w{Title Description Solution}.each do |field|
        prompt << "#{field}: #{Issue.find(issue_id).fields[field]}\n\n"
      end

      response_id = SecureRandom.hex(10)

      Turbo::StreamsChannel.broadcast_prepend_to [interaction_id, 'prompts'],
        target: 'messages',
        partial: 'dradis/plugins/echo/prompts/response',
        locals: { prompt: prompt, response_id: response_id}

      begin
        client.generate(
          {
            model: Engine.settings.model,
            prompt: prompt
          }
        ) do |event, raw|
          process_event(event, response_id, interaction_id)
        end

      rescue Ollama::Errors::OllamaError => error
        msg = '<div class="alert alert-danger">There was an error contacting Ollama: '
        msg << error.message
        msg << '</div>'
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: msg
      end
    end

    private
    def client
      @client ||= Ollama.new(
        credentials: { address: Engine.settings.address },
        options: { server_sent_events: true }
      )
    end

    def process_event(event, response_id, interaction_id)
      done = event['done']
      if done
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: '<p>Done.</p>'
      else
        message = event['response'].to_s.strip.empty? ? "<br/>" : event['response']
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: response_id, html: message
      end
    end
  end
end