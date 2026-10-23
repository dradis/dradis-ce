module Dradis::Plugins::Echo
  module Prompt::Defaults
    extend ActiveSupport::Concern

    DEFAULTS = {
      issue: [
        {
          title: 'Summarize',
          icon: 'fa-wand-magic-sparkles',
          scope: :issue,
          prompt: <<~EOP
            I am a cyber security professional working on a cybersecurity assessment.

            I found a vulnerability and I'd like for you to help me craft a concise
            description of the impact it has on the security posture of the environment.

            I will include this description along with others in the Executive Summary
            section of my security assessment report deliverable. Ideally it should be
            no more than a single sentence.

            These are the finding's details:

            # Title
            {{ issue.title }}

            # Description
            {{ issue.fields['Description'] }}

            # Solution
            {{ issue.fields['Solution'] }}
          EOP
        },

        {
          title: 'Reword',
          icon: 'fa-shuffle',
          scope: :issue,
          prompt: <<~EOP
            I am a cyber security professional working on a cybersecurity assessment.

            I found a vulnerability and I'd like for you to help me craft a
            description and recommendation that's going to make it easy to understand
            for the owners of the system I'm testing.

            So far, this is what I've got, please give me your suggestions:

            # Title
            {{ issue.title }}

            # Description
            {{ issue.fields['Description'] }}

            # Solution
            {{ issue.fields['Solution'] }}
          EOP
        },

        {
          title: 'Haiku',
          icon: 'fa-feather-pointed',
          scope: :issue,
          prompt: <<~EOP
            I want to create a haiku inspired by the following text:
            {{ issue.text }}
          EOP
        }
      ]
    }.freeze

    class_methods do
      def defaults_for(scope)
        DEFAULTS.fetch(scope.to_sym, []).map { |attrs| new(attrs) }
      end

      # Checks emptiness per scope, not globally, so a user with prompts in
      # one scope still gets another scope's defaults backfilled.
      def find_or_seed_for(user, scope = nil)
        scopes = scope.nil? ? Prompt::SCOPES : [scope]

        scopes.flat_map do |s|
          prompts = user.prompts.for(s)
          next prompts unless prompts.empty?

          user.prompts << defaults_for(s)
          user.prompts.for(s)
        end
      end
    end
  end
end
