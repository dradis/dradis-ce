module Dradis::Plugins::Echo
  class Agent < ApplicationRecord
    enum :agent_type, %i[system user], default: :user

    # -- Relationships --------------------------------------------------------
    belongs_to :provider

    # -- Callbacks ------------------------------------------------------------
    after_save :persist_language_tool_address
    before_destroy :prevent_system_deletion

    # -- Validations ----------------------------------------------------------
    validates :name, presence: true, uniqueness: true

    # -- Scopes ---------------------------------------------------------------

    # -- Class Methods --------------------------------------------------------

    # -- Instance Methods -----------------------------------------------------
    attr_writer :language_tool_address

    def language_tool_address
      @language_tool_address || Roslin::LanguageTool.settings.address.presence || Roslin::LanguageTool::DEFAULT_ADDRESS
    end

    private

    def persist_language_tool_address
      return unless @language_tool_address

      Roslin::LanguageTool.settings.address = @language_tool_address.presence || Roslin::LanguageTool::DEFAULT_ADDRESS
      Roslin::LanguageTool.settings.save
    end

    # System agents (e.g. Roslin) are seeded by migration and must not be deleted.
    def prevent_system_deletion
      throw(:abort) if system?
    end
  end
end
