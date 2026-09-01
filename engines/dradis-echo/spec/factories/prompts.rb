FactoryBot.define do
  factory :echo_prompt, class: 'Dradis::Plugins::Echo::Prompt' do
    user
    sequence(:title) { |n| "Prompt #{n}" }
    icon { 'fa-star-of-life' }
    prompt { 'Summarize {{ issue.title }}' }
    scope { :issue }
    visibility { :user }
  end
end
