# Create a few default tags.
Tag::DEFAULT_TAGS.each do |name|
  Tag.find_or_create_by(name: name)
end
