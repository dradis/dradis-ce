module Previewable
  extend ActiveSupport::Concern

  def preview
    @text = params[:text]
    render 'markup/preview', layout: false
  end

  private

  def set_form_preview_path
    @form_preview_path = nil
  end
end
