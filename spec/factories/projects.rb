FactoryBot.define do
  factory :project do
    skip_create

    transient do
      id { 1 }
    end
  end
end
