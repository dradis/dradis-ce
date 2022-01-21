module CachedColumns
  CACHE_KEY = "%{identifier}/%{record_type}/column-keys/%{tail}".freeze

  # Takes an ActiveRecord::Relation so we can make one more query off it
  def cached_collection_column_keys(collection, extra_columns, identifier: @current_project.id)
    last_updated_record = collection.order(updated_at: :desc).first
    # Exit early if the collection is empty.
    return extra_columns unless last_updated_record

    last_updated = last_updated_record.updated_at.to_i

    key_opts = { identifier: identifier, record_type: last_updated_record.class.name }

    Rails.cache.fetch(CACHE_KEY % key_opts.merge(tail: last_updated)) do
      # Delete any old key before we write the new one
      Rails.cache.delete_matched(CACHE_KEY % key_opts.merge(tail: '*'))

      collection.map(&:fields).map(&:keys).uniq.flatten | extra_columns
    end
  end
end
