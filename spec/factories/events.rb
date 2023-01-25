FactoryBot.define do
    factory :event, :class => Ahoy::Event do
        sequence(:name) { |n| "event#{n}" }
        association :visit
    end
end
