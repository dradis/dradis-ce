FactoryBot.define do
  factory :tag do
    sequence(:name){ |n| "tag-#{n}" }

    trait :color do
      name { "!#{[('a'..'z'), ('0'..'9')].map(&:to_a).flatten.sample(6).join}_#{[('a'..'z'), ('0'..'9')].map(&:to_a).flatten.sample(6).join}" }
    end
  end
end
