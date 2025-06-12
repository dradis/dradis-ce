module Dradis::Plugins::Echo
  class EchoJob < ApplicationJob
    queue_as :default

    def perform(prompt_id:, klass: , record_id: , interaction_id:)
      sleep 2

      prompt_template = Prompt.default[klass].select { |prompt| prompt.id == prompt_id.to_i }.first
      Rails.logger.info("🎬 #{prompt_template.prompt}")
      prompt = parse(prompt_template.prompt, { 'issue' => IssueDrop.new(Issue.find(record_id)) })
      Rails.logger.info("🔚 #{prompt}")

      response_id = SecureRandom.hex(10)

      Turbo::StreamsChannel.broadcast_update_to [interaction_id, 'prompts'],
        target: 'messages',
        partial: 'dradis/plugins/echo/prompts/response',
        locals: { prompt: prompt, response_id: response_id, template: prompt_template }

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
        msg = '<div class="alert alert-danger m-0">There was an error contacting Ollama: '
        msg << error.message
        msg << '</div>'
        Turbo::StreamsChannel.broadcast_update_to [interaction_id, 'prompts'], target: response_id, html: msg
      end
    end

    private
    def client
      @client ||= Ollama.new(
        credentials: { address: Engine.settings.address },
        options: { server_sent_events: true }
      )
    end

    def parse(template, assigns)
      options = {
        filters: [],
        strict_filters: true,
        strict_variables: true
      }

      Liquid::Template.parse(template).render(assigns, options)
    end

    def process_event(event, response_id, interaction_id)
      done = event['done']
      if done
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: '<p>Done.</p>'
      else
        message = event['response'].to_s.strip.empty? ? "<br/>" : event['response']
        message.sub!('<think>', '{thinking}')
        message.sub!('</think>', '{/thinking}')
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: response_id, content: message
      end
      Turbo::StreamsChannel.broadcast_remove_to [interaction_id, 'prompts'], target: "#{response_id}_spinner"
    end
  end
end
