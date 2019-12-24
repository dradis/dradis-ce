# frozen_string_literal: true

every 10.minutes do
  thor 'dradis:digests:send_instants'
end

every 1.day, at: '9:00' do
  thor 'dradis:digests:send_dailies'
end
