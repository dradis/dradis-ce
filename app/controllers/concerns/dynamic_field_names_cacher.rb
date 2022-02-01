module DynamicFieldNamesCacher
  CACHE_KEY = "%{identifier}/%{record_type}/column-keys/%{tail}".freeze

  # Takes an ActiveRecord::Relation so we can make one more query off it
  def dynamic_field_names(collection, identifier = nil)
    return [] if collection.empty?

    last_updated_record = collection.order(updated_at: :desc).first
    last_updated = last_updated_record.updated_at.to_i

    identifier ||= "projects-#{@current_project.id}"
    key_opts = { identifier: identifier, record_type: last_updated_record.class.name }

    Rails.cache.fetch(CACHE_KEY % key_opts.merge(tail: last_updated)) do
      # Delete any old key before we write the new one
      Rails.cache.delete_matched(CACHE_KEY % key_opts.merge(tail: '*'))

      collection.map(&:fields).map(&:keys).uniq.flatten
    end
  end
end
