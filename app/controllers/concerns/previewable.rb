module Previewable
  extend ActiveSupport::Concern

  def preview
    @text = params[:text]
    render 'markup/preview', layout: false
  end
end
