Rails.application.config.action_view.form_with_generates_remote_forms = true

Rails.application.reloader.to_prepare do
  Rails.application.config.active_record.yaml_column_permitted_classes = [ActiveModel::Errors, Symbol, UserPreferences]
end

