# Content can contain invalid UTF-8 byte sequences. MySQL can be configured
# to reject these at the DB layer, but CE runs on SQLite, which has no
# charset enforcement at all, so DB-level rejection can't be the shared fix
# across editions. Scrub instead, so an unscrubbed value never reaches the
# DB and never raises an unhandled ArgumentError later, wherever it happens
# to be read first rather than where it was written.
#
# ActiveModel::Type::String is the shared base type behind every :string and
# :text column (ActiveRecord::Type::String and ActiveRecord::Type::Text both
# inherit from it), so scrubbing here covers every column of both types, on
# every model and every adapter, without registering per model or column.
module ScrubsInvalidEncoding
  def cast(value)
    value = value.scrub if value.is_a?(String)
    super
  end
end

ActiveModel::Type::String.prepend(ScrubsInvalidEncoding)
