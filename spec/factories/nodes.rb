FactoryGirl.define do
  factory :node do
    label "Node-#{Time.now.to_i}"
    parent_id nil
  end
end
