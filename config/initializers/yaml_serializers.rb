Rails.application.reloader.to_prepare do
  ActiveRecord.yaml_column_permitted_classes = [
    ActiveModel::Errors,
    ActiveModel::ValidationContext,
    ActiveSupport::TimeWithZone,
    ActiveSupport::TimeZone,
    Date,
    Symbol,
    Time,
    UserPreferences
  ]
end
