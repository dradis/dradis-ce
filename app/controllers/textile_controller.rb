class TextileController < AuthenticatedController
  def form
    if params[:form]
      @form_data = Hash[ *params[:form].scan(HasFields::REGEX).flatten.map(&:strip) ]
    end

    render layout: false
  end

  def source
    render plain: build_source
  end

  private

  def build_source
    form_data = JSON.parse(params[:form])

    form_data.each_slice(2).map do |field_name, field_value|
      "#[#{field_name['value']}]#\n#{field_value['value']}"
    end.join("\n\n")
  end

  def form_params
    params.require.permit(:form)
  end
end
