# This class represents a Note category. Each Category has a name.
class Category < ApplicationRecord

  # -- Relationships --------------------------------------------------------


  # -- Callbacks ------------------------------------------------------------
  before_destroy :valid_destroy


  # -- Validations ----------------------------------------------------------


  # -- Scopes ---------------------------------------------------------------


  # -- Class Methods --------------------------------------------------------
  def self.default
    Category.find_or_create_by(name: 'Default category')
  end

  def self.issue
    Category.find_or_create_by(name: 'Issue description')
  end

  def self.report
    Category.find_or_create_by(name: 'Report category')
  end

  # -- Instance Methods -----------------------------------------------------

  private
  def valid_destroy
    if (self.id == 1)
      self.errors.add :base, 'Cannot delete Default category.'
    end
    if Note.count(conditions: { category_id: self.id }) > 0
      self.errors.add :base, 'Cannot delete Category with notes.'
    end
    return errors.count.zero? ? true : false
  end
end
