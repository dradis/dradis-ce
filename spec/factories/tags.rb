FactoryBot.define do
  factory :tag do
    name { "!#{Random.bytes(3).unpack1('H*')}_tag" }
  end
end
