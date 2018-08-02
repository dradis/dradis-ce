FactoryBot.define do
  factory :project do
    skip_create

    ignore do
      id 1
    end
  end
end
