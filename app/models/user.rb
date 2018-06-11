class User < ApplicationRecord
  # -- Table-less ActiveRecord hackery ----------------------------------------
  def self.columns
    @columns ||= [];
  end

  def self.column(name, default = nil, sql_type_metadata = nil, null = true)
    # Warning: this is relying undocumented Rails behaviour that may change
    # without notice. (Last tested on Rails 5.0.0.1)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type_metadata, null)
  end

  attr_accessor :email

  column :email, ActiveRecord::Type::String
  # column :preferences, :text

  # Danger Will Robinson
  tmp = connection.schema_cache.instance_variable_get('@columns')
  tmp['users'] = columns

  # Override the save method to prevent exceptions.
  def save(validate = true)
    raise 'save!'
    validate ? valid? : true
  end

  def id; 1; end
  def new_record?; false; end
  def persisted?; true; end

  # -- Relationships --------------------------------------------------------
  has_many :activities
  has_many :comments

  # -- Callbacks ------------------------------------------------------------
  # -- Validations ----------------------------------------------------------
  validates :email,
    # uniqueness: { allow_blank: false },
    format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i }

  # -- Scopes ---------------------------------------------------------------
  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
