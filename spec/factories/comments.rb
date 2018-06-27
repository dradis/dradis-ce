FactoryBot.define do
  factory :comment do
    commentable { |comment| comment.association :issue }
    sequence(:content) { |n| "Comment #{n}" }
    association :user
  end
end
