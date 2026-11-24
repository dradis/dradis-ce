module ConsolesHelper
  CONSOLE_SUMMARIES = {
    completed: 'Complete.',
    failed: 'Failed. See the log below for details.',
    idle: 'Waiting to start',
    running: 'Working…'
  }.freeze

  def console_summary(state)
    CONSOLE_SUMMARIES.fetch(state.to_sym)
  end
end
