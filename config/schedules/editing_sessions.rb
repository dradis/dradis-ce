# frozen_string_literal: true

every 1.day, at: '3:00' do
  thor 'dradis:editing_sessions:purge_stale'
end
