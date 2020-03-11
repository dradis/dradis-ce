class TagForm
  include ActiveModel::Model

  attr_accessor :color, :name, :id

  validates :name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: 'only allows letters. No spaces or special characters.' }

  def save
    if valid?
      tag = Tag.find_by_id(id) || Tag.new
      tag.name = assign_name
      tag.save
      true
    else
      false
    end
  end

  private

  def assign_name
    "#{color.gsub('#', '!')}_#{name}"
  end
end
