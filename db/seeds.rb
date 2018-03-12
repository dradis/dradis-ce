# Create a few default tags.
[
  '!9467bd_Critical',
  '!d62728_High',
  '!ff7f0e_Medium',
  '!6baed6_Low',
  '!2ca02c_Info',
].each do |name|
  Tag.create(name: name)
end
