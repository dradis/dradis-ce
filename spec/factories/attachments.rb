FactoryBot.define do
  factory :attachment do
    skip_create

    sequence(:filename) { |n| "image#{n}.png" }
    node

    initialize_with {
      FileUtils.mkdir_p Attachment.pwd.join(node.id.to_s).to_s
      FileUtils.cp Rails.root.join("spec/fixtures/files/rails.png").to_s,
                   Attachment.pwd.join(node.id.to_s, filename).to_s
      Attachment.find(filename, conditions: { node_id: node.id } )
    }
  end
end
