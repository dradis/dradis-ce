class RenameLegacyTags < ActiveRecord::Migration[5.1]
  # Future-proof this migration by ignoring model's default_scope
  # https://discuss.rubyonrails.org/t/skip-default-scope-when-running-migrations/46906/2
  class Tag < ActiveRecord::Base; end

  def up
    Tag.all.each do |tag|
      case tag.name
      when '!9467bd'
        tag.update_attribute :name, '!9467bd_Purple'
      when '!d62728'
        tag.update_attribute :name, '!d62728_Red'
      when '!ff7f0e'
        tag.update_attribute :name, '!ff7f0e_Orange'
      when '!2ca02c'
        tag.update_attribute :name, '!2ca02c_Green'
      when '!6baed6'
        tag.update_attribute :name, '!6baed6_Blue'
      else
        # ignore, nothing to do
      end
    end;nil
  end

  def down
    # Nothing to do, having tags with complete names won't hurt and is also
    # backwards compatible.
  end
end
