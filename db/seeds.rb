unless defined?(Dradis::Pro)
  # Create a few default tags.
  Tag::DEFAULT_TAGS.each do |name|
    Tag.find_or_create_by(name: name)
  end
end

# Seed Pro-specific engines if available
if defined?(Dradis::Pro)
  # Load engine seeds
  Dradis::Pro::BI::Engine.load_seed
  Dradis::Pro::Rules::Engine.load_seed
end
