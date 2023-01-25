FactoryBot.define do
    factory :visit, :class => Ahoy::Visit do
      visit_token { SecureRandom.uuid }
      started_at { Date.today }
    end
end
