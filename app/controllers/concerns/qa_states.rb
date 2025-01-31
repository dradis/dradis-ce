module QAStates
  extend ActiveSupport::Concern

  included do
    before_action :set_states, only: [:new, :edit]
  end

  private

  def set_states
    @states = Issue.states.dup
    @states.delete('published') unless can?(:publish, current_project)
  end
end
