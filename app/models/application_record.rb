class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  DB_MAX_STRING_LENGTH = 255
  DB_MAX_TEXT_LENGTH = 4294967295
end
