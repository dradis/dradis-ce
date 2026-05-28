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

    private

    # System agents (e.g. Roslin) are seeded by migration and must not be deleted.
    def prevent_system_deletion
      throw(:abort) if system?
    end
  end
end
