module Dradis::Plugins::Echo
  class EchoJob < ApplicationJob
    queue_as :dradis_project

    def perform(prompt:, interaction_id:, response_id:)
      # Add delay to allow the browser to subscribe to the Turbo Stream.
      sleep 2

      Rails.logger.info("🎬 #{prompt}")
      Rails.logger.info("🔚 #{prompt}")

      @spinner_shown = true
      begin
        client.generate(
          {
            model: Engine.settings.model,
            prompt: prompt
          }
        ) do |event, raw|
          process_event(event, response_id, interaction_id)
        end
      rescue Ollama::Errors::OllamaError => e
        msg = '<div class="alert alert-danger m-0">There was an error contacting Ollama: '
        msg << e.message
        msg << '</div>'
        Turbo::StreamsChannel.broadcast_update_to [interaction_id, 'prompts'], target: response_id, html: msg
      rescue Exception => e
        msg = '<div class="alert alert-danger m-0">'
        msg << e.message
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

    def process_event(event, response_id, interaction_id)
      done = event['done']
      if done
        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: '<p>Done.</p>'
      else
        message = event['response'] unless event['response'].to_s.strip.empty?
        if message
          # This replaces the html tags to display the thinking section of the
          # response. This has been known to show up in the following ollama
          # models:
          # - deepseek-r1:latest
          # - deepseek-r1:1.5b
          message = message.sub('<think>', '{thinking}').sub('</think>', '{/thinking}')

          Turbo::StreamsChannel.broadcast_append_to(
            [interaction_id, 'prompts'],
            target: response_id,
            content: message
          )
        end

        if @spinner_shown && message
          Turbo::StreamsChannel.broadcast_remove_to [interaction_id, 'prompts'], target: "#{response_id}_spinner"
          @spinner_shown = false
        end
      end
    end
  end
end
