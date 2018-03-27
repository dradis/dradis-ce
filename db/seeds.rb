# Create a few default tags.
[
  '!9467bd_critical',
  '!d62728_high',
  '!ff7f0e_medium',
  '!6baed6_low',
  '!2ca02c_info',
].each do |name|
  Tag.create!(name: name)
end
