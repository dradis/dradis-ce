# Create a few default tags.
Tag::DEFAULT_TAGS.each do |name|
  Tag.create!(name: name)
end
