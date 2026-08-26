module Dradis::Plugins::Echo
  class Agent < ApplicationRecord
    enum :agent_type, %i[system user], default: :user

    store :env, coder: JSON

    # -- Relationships --------------------------------------------------------
    belongs_to :provider

    # -- Callbacks ------------------------------------------------------------
    before_destroy :prevent_system_deletion

    # -- Validations ----------------------------------------------------------
    validates :name, presence: true, uniqueness: true

    # -- Scopes ---------------------------------------------------------------

    # -- Class Methods --------------------------------------------------------

    # -- Instance Methods -----------------------------------------------------

    # The model actually sent to the provider: the agent's override when set,
    # otherwise the provider's default. Keeps the override-vs-default resolution
    # in one place instead of repeating `model_override.presence || ...` at every
    # call site.
    def resolved_model
      model_override.presence || provider.model
    end

    private

    # The engine provisions system agents (e.g. Roslin), and they must not be deleted.
    def prevent_system_deletion
      throw(:abort) if system?
    end
  end
end
