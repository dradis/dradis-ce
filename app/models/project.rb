class Project
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def id; 1; end

  def name; 'Dradis CE'; end

  def persisted?; true; end
end
