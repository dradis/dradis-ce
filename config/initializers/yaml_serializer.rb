Rails.application.config.after_initialize do
  Rails.application.config.active_record.yaml_column_permitted_classes = [
    ActiveModel::Errors,
    ActiveSupport::TimeWithZone,
    ActiveSupport::TimeZone,
    Date,
    Symbol,
    Time,
    UserPreferences
  ]
end
