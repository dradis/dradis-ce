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

    I found a vulnerability and I'd like for you to help me craft a
    description and recommendation that's going to make it easy to understand
    for the owners of the system I'm testing.

    So far, this is what I've got, please give me your suggestions.

    Title: {{ issue.title }}
    Description: {{ issue.description }}
    Solution: {{ issue.solution }}
    EOP
          ),
          new(
            id: 2,
            title: 'Reword',
            icon: '🔀',
          )
        ]
      }
    end
    # -- Instance Methods -------------------------------------------------------
  end
end
