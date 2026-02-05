module Dradis::Plugins::Echo
  class Prompt < ApplicationRecord
    enum :visibility, [ :personal, :shared ]

    # -- Relationships ----------------------------------------------------------
    belongs_to :user

    # -- Callbacks --------------------------------------------------------------
    # -- Validations ------------------------------------------------------------
    # -- Scopes -----------------------------------------------------------------
    # -- Class Methods ----------------------------------------------------------
    def self.default
      [
        new(
          title: 'Summarize',
          icon: 'fa-wand-magic-sparkles',
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
        ),

        new(
          title: 'Reword',
          icon: 'fa-shuffle',
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
        ),

        new(
          title: 'Haiku',
          icon: 'fa-feather-pointed',
          prompt: <<~EOP
        I want to create a haiku inspired by the following text:
        {{ issue.text }}
        EOP
        )
      ]
    end
  end
end
