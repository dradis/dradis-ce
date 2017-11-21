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

  # Private: Adding a :services key to the node properties is a special case.
  # We only allow a set of known columns in the :services table.
  # The allowed columms are :name, :port, :product, :protocol, :reason, :state,
  # :version
  # Extra columns can be added as an array of hashes with fields :source, :id
  # and :output inside the :extra column.
  # These hashes in the :extra column are saved in the :services_extra table.
  # We check if a row exists in the :services and :services_extra tables
  # by matching the port and protocol columns.
  #
  # value - The new entry (Hash) we want to add to :services
  #         (and may be :services_extra) tables
  #
  # Returns the updated services table
  def add_service(value)
    # extract extra info from value
    value_extra = value.slice(:port, :protocol, :extra)
    value.slice!(:name, :port, :product, :protocol, :reason, :state, :version)

    merge_service(value)

    if value_extra[:extra]
      value_extra[:extra].select! { |extra| !extra[:output].blank? }
      if value_extra[:extra].any?
        merge_service_extra(value_extra)
      end
    end

    self.properties[:services]
  end

  # Private: Merges a Hash into an Array of Hashes by :port and :protocol keys.
  # If a row exists in the table with the new row port and protocol values, the
  # rest of the columns that have the same name and different values
  # are concatenated (as strings)
  #
  # table   - the existing table where we want to merge a new entry.
  #         May be nil, a Hash or an Array of hashes
  # new_row - the new entry (a Hash) we want to put in the existing table.
  #
  # Returns table with new_row merged
  def merge_service(new_row)
    table = self.properties[:services]

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
      # if the row is in the table, merge it
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

    self.properties[:services] = table
  end

  # Private: Merges a Hash into an Array of Hashes by :port and :protocol keys.
  # Destination table looks like:
  #   [
  #     {
  #      port: 80,
  #      protocol: 'tcp',
  #      extra: [ {source:, id: output:}, {source:, id: output:}]
  #     },
  #     ...
  #   ]
  # Both the destination hash and the new one have an :extra key, which is an
  # array (of hashes with :source, :id and :output keys). If some of the hashes
  # is not present in the destination row, it is added. If the destination row
  # doesn't exist at all it is created.
  #
  # table   - the existing table where we want to merge a new entry.
  #         May be nil, a Hash or an Array of hashes
  # new_row - the new entry (a Hash) we want to put in the existing table.
  #
  # Returns table with new_row merged
  def merge_service_extra(new_row)
    table = self.properties[:services_extra]

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
      # if the row is in the table, merge it
      target = table[position]
      new_row[:extra].each do |extra|
        target[:extra] << extra unless target[:extra].include?(extra)
      end

      table[position] = target
    end

    self.properties[:services_extra] = table
  end
end
