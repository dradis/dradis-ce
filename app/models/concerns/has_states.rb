module HasStates
  extend ActiveSupport::Concern

  included do
    before_save do
      self[:state] = buffered_state
    end

    validate :state_is_valid
  end

  # We are encapsulating the actual state in a variable so we can temporarily
  # store an invalid value and perform a validation. Otherwise, assigning an
  # invalid value will throw an ArugmentError.
  # SEE: https://github.com/rails/rails/issues/13971
  def buffered_state
    @buffered_state ||= self[:state]
  end

  def state
    buffered_state
  end

  def state=(state)
    @buffered_state = state
  end

  private

  # A valid state can be of the state name or the state index.
  def state_is_valid
    if !Issue.states.keys.include?(buffered_state.to_s) &&
        !Issue.states.values.include?(buffered_state)

      errors.add(:state, 'is invalid.')
    end
  end
end
