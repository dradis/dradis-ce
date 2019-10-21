# This class provides a flexible way to store user preferences using
# ActiveRecord's @serialize@ technique.
#
# This class is a bit of sugar on top of a standard `serialize :prefs, Hash`
# call as we can inspect the attributes and add additional logic without
# bloating the User model.
#
# The Class methods deal with ActiveRecord dump() and load(), and the Instance
# methods deal with user preferences.
#
# See:
#   http://viget.com/extend/how-i-used-activerecord-serialize-with-a-custom-data-type
#   http://ruby-journal.com/how-to-write-custom-serializer-for-activerecord-number-serialize/

class UserPreferences
  class InvalidTourException < Exception; end
  include ActiveModel::Validations

  VALID_TOURS = %i[first_sign_in projects_show]
  DIGEST_FREQUENCIES = %i[none instant daily].freeze

  validates :digest_frequency,
    inclusion: {
      in: DIGEST_FREQUENCIES,
      digest_frequencies: "'#{DIGEST_FREQUENCIES.join("', '")}'"
    }

  # -- Class Methods ----------------------------------------------------------
  # Used for `serialize` method in ActiveRecord
  def self.dump(obj)
    return if obj.nil?

    unless obj.is_a?(self)
      raise ::ActiveRecord::SerializationTypeMismatch,
        "Attribute was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
    end

    # YAML.dump(obj.attributes)
    YAML.dump(obj)
  end

  def self.load(yaml)
    return self.new if self != Object && yaml.nil?
    return yaml unless yaml.is_a?(String) && yaml =~ /^---/

    obj = YAML.load(yaml)

    unless obj.is_a?(self) || obj.nil?
      raise SerializationTypeMismatch,
        "Attribute was supposed to be a #{self}, but was a #{obj.class}"
    end

    obj ||= self.new if self != Object

    # self.new(obj)
    obj
  end


  # -- Instance Methods -------------------------------------------------------

  # Preferences:
  #   tours - This setting stores a dictionary of all the tours this user has
  #           seen. Since we can have multiple versions of each tour we need
  #           to be able to track what was the last version we presented to
  #           them. See TourRegistry class.
  #
  #   digest_frequency - A user preference for how often they wish to receive
  #                      notification emails.
  attr_accessor :tours, :digest_frequency

  def initialize(args={})
    @tours = Hash.new { |hash, key| hash[key] = '0' }
    @digest_frequency = :none

    args.each do |key, value|
      if key.to_s =~ /\Atour_([\w_]*)\z/
        @tours[$1.to_sym] = value
      end
    end
  end

  # ----------------------------------------------------------------- YAML.load
  # This deals with YAML.load and legacy preferences
  def init_with(coder)
    coder.map.each do |key, value|
      # Move the legacy :last_tour preference under the tour registry
      # Also, the legacy preferences don't have a :tours attribute
      if key == 'last_tour'
        @tours = Hash.new { |hash, key| hash[key] = '0' }
        @tours[:projects_show] = value
      elsif key == 'tour' && value == {}
        @tours = Hash.new { |hash, key| hash[key] = '0' }
      else
        instance_variable_set(:"@#{key}", value)
      end
    end
  end


  def method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /\Alast_([\w_]*)=?\z/
      method = $1
      raise InvalidTourException.new('Tour not found!') unless VALID_TOURS.include?(method.to_sym)

      if method_sym.to_s.ends_with?('=')
        @tours[method.to_sym] = arguments.first
      else
        @tours[method.to_sym]
      end
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /\Alast_([\w_]*)\z/
      method = $1
      if VALID_TOURS.include?(method.to_sym)
        true
      else
        false
      end
    else
      super
    end
  end
end
