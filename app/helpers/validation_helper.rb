module ValidationHelper
  def validation_icon
    content_tag :div, class: 'validation' do
      #if passing validation
        content_tag :i, class: 'fa fa-check fa-fw ml-4' do end
      #else
        #content_tag :i, class: 'fa fa-times fa-fw ml-4' do end
      #end
    end
  end
end
