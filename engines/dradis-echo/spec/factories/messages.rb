FactoryBot.define do
  factory :echo_message, class: 'Dradis::Plugins::Echo::Message' do
    association :session, factory: :echo_session
    user
    role { :user }
    content { 'Hello, Echo.' }

    factory :assistant_message do
      role { :assistant }
      user { nil }
      content { 'Hello back.' }
    end
  end
end
