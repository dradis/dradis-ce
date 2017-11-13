require 'json_validator'
require 'json_with_indifferent_access'

# Note: looks like we're deviating from Rails expected conventions. Maybe
# reimplement in light of:
#   https://nvisium.com/blog/2015/06/22/using-rails-5-attributes-api-today-in/
module NodeProperties
  def self.included(base)
    @base = base

    base.class_eval do
      # Node properties:
      # * Serialized as JSON
      # * The smart setter set_property(key, value) takes care of duplications, etc.
      serialize :properties, JSONWithIndifferentAccess

      validates :raw_properties, json: { message: 'contains invalid JSON' }
    end
  end

  # -------------------------------------------- Individual property management
  # Sets a property, storing value as Array when needed
  # and taking care of duplications
  def set_property(key, value)
    current_value = self.properties[key]

    # Even though we're serializing JSONWithIndifferentAccess, and the
    # properties can be returned using String or Symbol keys, the
    # :value_is_there variable defined bellow is depending on Array's #include?
    # and this method wouldn't match two hashes unless they're both
    # #with_indifferent_access
    value = value.with_indifferent_access if value.is_a?(Hash)

    value_is_there = (current_value == value) || (current_value.is_a?(Array) && current_value.include?(value))
    return current_value if value.blank? || value_is_there

    if key == :services
      add_service(value)
    elsif current_value.blank?
      self.properties[key] = value
    else
      self.properties[key] = [current_value, value].flatten.uniq
    end

    self.properties[key] = self.properties[key].first if self.properties[key].size == 1

    return self.properties[key]
  end

  def has_any_property?
    self.properties.keys.any? { |p| self.properties[p].present? }
  end

  # -------------------------------------- :raw_properties accessors for the UI
  def raw_properties
    if self.has_any_property?
      JSON.pretty_generate(self.properties.to_hash)
    elsif @raw_properties
      @raw_properties
    else
      "{\n}"
    end
  end

  # We do this as a two-step operation:
  #   - First we try to detect JSON errors. If none are found, we set the
  #   Node's properties.
  #   - If there is an error, we keep the malformed value (to give the user a
  #   chance of fixing it), but don't assign the Node's properties.
  def raw_properties=(value)
    @raw_properties = JSON::parse(value)
    self.properties = @raw_properties
  rescue JSON::ParserError => exception
    @raw_properties = value
  end

private

  # Private: Adding a :services key to the node properties is a special case:
  #   * We check if a row exists in the services table by matching the port
  #     and protocol columns
  #   * We only allow a set of known columns in the :services table. The rest
  #     of columns are moved to an extra data table called 'supplemental'. The
  #     allowed columms are :name, :port, :product, :protocol, :reason, :state,
  #     :version
  # value - The new entry (Hash) we want to add to :services table
  #
  # Returns the updated services table
  def add_service(value)
    services     = self.properties[:services]
    supplemental = self.properties[:supplemental]

    # extract extra info from value
    extra_value = value.except(:name, :product, :reason, :state, :version)
    value.slice!(:name, :port, :product, :protocol, :reason, :state, :version)

    self.properties[:services] = merge_by_port_and_protocol(services, value)

    if extra_value.except(:port, :protocol).any?
      supplemental = merge_by_port_and_protocol(supplemental, extra_value)
      supplemental = supplemental.first if supplemental.size == 1
      self.properties[:supplemental] = supplemental
    end

    self.properties[:services]
  end

  # Private: Merges a Hash into an Array of Hashes by :port and :protocol keys.
  # If a row exists in the table with the new row port and protocol values, the
  # rest of the columns that have the same name are concatenated.
  #
  # table   - the existing table where we want to merge a new entry.
  #         May be nil, a Hash or an Array of hashes
  # new_row - the new entry (a Hash) we want to put in the existing table.
  #
  # Returns table with new_row merged
  def merge_by_port_and_protocol(table, new_row)
    # work always with an array of hashes
    table = [table] if table.is_a?(Hash)
    table = [] if table.nil?

    # find new_row in table
    position = table.find_index do |row|
      row.values_at(:port, :protocol) == new_row.values_at(:port, :protocol)
    end

    if position.nil?
      # if the row was not in the table, add it
      table << new_row
    else
      # if the row is in th etable, merge it
      target = table[position]
      target.merge!(new_row) do |_key, oldvalue, newvalue|
        if oldvalue == newvalue
          oldvalue
        else
          [oldvalue.split(' | '), newvalue].flatten.uniq.join(' | ')
        end
      end

      table[position] = target
    end

    table
  end
end
