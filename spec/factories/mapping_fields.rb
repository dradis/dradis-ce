FactoryBot.define do
  factory :mapping_field do
    mapping { create(:mapping) }
    destination_field { 'title' }
    source_field { 'title' }
    content { 'test content' }
  end
end
