module Analytic
  extend ActiveSupport::Concern
  included do
    before_action :find_or_initialize_analytics
  end

  protected

  def find_or_initialize_analytics
    @analytics_config = ::Configuration.find_or_initialize_by(name: 'admin:analytics')
  end
end
