module UploaderFinder
  extend ActiveSupport::Concern

  included do
    before_action :set_uploaders
    before_action :validate_uploader, only: [:create, :parse]
  end

  private

  def set_uploaders
    # :upload plugins can define multiple uploaders
    @uploaders ||= Dradis::Plugins::with_feature(:upload).
                     map(&:uploaders).
                     flatten.
                     sort_by(&:name)
  end

  # Ensure that the requested :uploader is valid and has been included in the
  # Plugins::Upload mixin
  def validate_uploader
    return unless upload_params[:uploader]
    uploader = @uploaders.find { |uploader| uploader.name == upload_params[:uploader] }

    if uploader
      @uploader = uploader
    else
      redirect_to :back, alert: 'Something fishy is going on...'
    end
  end

  def upload_params
    params.permit(:uploader)
  end
end
