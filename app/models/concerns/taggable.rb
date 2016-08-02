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
      tag = Tag.where('name LIKE ?', "%_#{n.strip.downcase}").first
      tag.present? ? tag : Tag.where(name: n.strip.downcase).first_or_create!
    end
  end
end
