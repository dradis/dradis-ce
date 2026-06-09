module Dradis::Plugins::Echo
  class InteractionJob < ApplicationJob
    queue_as :dradis_project

    def perform(agent_id:, prompt:, interaction_id:, response_id:)
      agent = Agent.find(agent_id)
      raise "Agent '#{agent.name}' is not enabled" unless agent.enabled?

      spinner_shown = true

      agent.provider.generate(prompt: prompt, model: agent.model_override) do |chunk|
        if spinner_shown
          Turbo::StreamsChannel.broadcast_remove_to [interaction_id, 'prompts'], target: "#{response_id}_spinner"
          spinner_shown = false
        end

        Turbo::StreamsChannel.broadcast_append_to(
          [interaction_id, 'prompts'],
          target: response_id,
          content: ERB::Util.html_escape(chunk)
        )
      end

      Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: '<p>Done.</p>'
    rescue => e
      msg = '<div class="alert alert-danger m-0">'
      msg << ERB::Util.html_escape(e.message)
      msg << '</div>'
      Turbo::StreamsChannel.broadcast_update_to [interaction_id, 'prompts'], target: response_id, html: msg
    end
  end
end
