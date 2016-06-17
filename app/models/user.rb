class User < ActiveRecord::Base
  # -- Table-less ActiveRecord hackery ----------------------------------------
  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    cast_type = ActiveRecord::Base.connection.send :lookup_cast_type, sql_type
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, cast_type, sql_type.to_s, null)
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

  # -- Callbacks ------------------------------------------------------------
  # -- Validations ----------------------------------------------------------
  validates :email,
    # uniqueness: { allow_blank: false },
    format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i }

  # -- Scopes ---------------------------------------------------------------
  # -- Class Methods --------------------------------------------------------
  # -- Instance Methods -----------------------------------------------------
end
