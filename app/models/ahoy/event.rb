class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = 'ahoy_events'

  belongs_to :visit

  serialize :properties, JSON
end
