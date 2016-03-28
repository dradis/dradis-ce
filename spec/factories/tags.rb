FactoryGirl.define do
  factory :tag do
    sequence(:name){ |n| "tag-#{n}" }
  end
end
