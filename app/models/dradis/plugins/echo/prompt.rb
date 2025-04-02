module Dradis::Plugins::Echo
  class Prompt
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :title, :string
    attribute :icon, :string
    attribute :prompt, :string

    # -- Relationships ----------------------------------------------------------
    # -- Callbacks --------------------------------------------------------------
    # -- Validations ------------------------------------------------------------
    # -- Scopes -----------------------------------------------------------------
    # -- Class Methods ----------------------------------------------------------
    def self.default
      {
        issue: [
          new(
            id: 1,
            title: 'Summarize',
            icon: '✨',
            prompt: <<~EOP
    I am a cyber security professional working an a cybersecurity assessment.

    I found a vulnerability and I'd like for you to help me craft a concise
    description of the impact it has on the security posture of the environment.

    I will include this description along with others in the Executive Summary
    section of my security assessment report deliverable. Ideally it should be
    no more than a single sentence.

    These are the finding's details:

    Title: {{ issue.title }}
    Description: {{ issue.fields['Description'] }}
    Solution: {{ issue.fields['Solution'] }}
    EOP
          ),
          new(
            id: 2,
            title: 'Reword',
            icon: '🔀',
            prompt: <<~EOP
    I am a cyber security professional working an a cybersecurity assessment.

    I found a vulnerability and I'd like for you to help me craft a
    description and recommendation that's going to make it easy to understand
    for the owners of the system I'm testing.

    So far, this is what I've got, please give me your suggestions.

    Title: {{ issue.title }}
    Description: {{ issue.fields['Description'] }}
    Solution: {{ issue.fields['Solution'] }}
    EOP
          )
        ]
      }.freeze
    end
    # -- Instance Methods -------------------------------------------------------
  end
end
