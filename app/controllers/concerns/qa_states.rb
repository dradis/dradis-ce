module QAStates
  extend ActiveSupport::Concern

  included do
    before_action :set_states, only: [:new, :edit]
  end

  private

  def set_states
    @states = Issue.states.dup
  end
end
