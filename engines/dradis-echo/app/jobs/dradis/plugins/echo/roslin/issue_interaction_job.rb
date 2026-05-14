module Dradis::Plugins::Echo
  class Roslin
    class IssueInteractionJob < ApplicationJob
      queue_as :dradis_project

      def perform(prompt:, interaction_id:, response_id:)
        Rails.logger.info("🎬 #{prompt}")

        raise 'Issue Interaction is not enabled' unless IssueInteraction.enabled?

        spinner_shown = true

        IssueInteraction.provider.generate(prompt: prompt, model: IssueInteraction.model) do |chunk|
          if spinner_shown
            Turbo::StreamsChannel.broadcast_remove_to [interaction_id, 'prompts'], target: "#{response_id}_spinner"
            spinner_shown = false
          end

          Turbo::StreamsChannel.broadcast_append_to(
            [interaction_id, 'prompts'],
            target: response_id,
            content: chunk
          )
        end

        Turbo::StreamsChannel.broadcast_append_to [interaction_id, 'prompts'], target: 'messages', html: '<p>Done.</p>'
      rescue => e
        msg = '<div class="alert alert-danger m-0">'
        msg << e.message
        msg << '</div>'
        Turbo::StreamsChannel.broadcast_update_to [interaction_id, 'prompts'], target: response_id, html: msg
      end
    end
  end
end
