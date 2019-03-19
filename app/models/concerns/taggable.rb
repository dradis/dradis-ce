# A shared Taggable concern
module Taggable
  def self.included(base)
    # base.extend ClassMethods

    base.class_eval do
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings
    end
  end

  # module ClassMethods
  # end
  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip.downcase).first_or_create!
    end
  end
end
