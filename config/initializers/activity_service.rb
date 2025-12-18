Rails.application.reloader.to_prepare do
  ActivityService.configure do |activity_service|
    activity_service.subscribe_namespace 'issue'
  end
end
