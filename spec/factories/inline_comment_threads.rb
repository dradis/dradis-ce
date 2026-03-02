FactoryBot.define do
  factory :inline_comment_thread do
    association :issue, state: :ready_for_review
    association :user
    anchor do
      {
        'type' => 'TextQuoteSelector',
        'exact' => 'Apache bugs',
        'prefix' => '#[Title]#\nRspec multiple ',
        'suffix' => '\n\n#[Description]#',
        'position' => { 'start' => 28, 'end' => 39 },
        'field_name' => 'Title'
      }
    end
    status { :open }
  end
end
