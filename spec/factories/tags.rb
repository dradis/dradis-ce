FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "!#{"%06d" % n}_tag" }
  end
end
