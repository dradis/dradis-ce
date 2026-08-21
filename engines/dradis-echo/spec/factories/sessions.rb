FactoryBot.define do
  factory :echo_session, class: 'Dradis::Plugins::Echo::Session' do
    agent
    association :record, factory: :note
    status { :idle }
  end
end
