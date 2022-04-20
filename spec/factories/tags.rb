FactoryBot.define do
  factory :tag do
    sequence(:name){ |n| "tag-#{n}" }

    transient do
      project {}
    end
  end
end
