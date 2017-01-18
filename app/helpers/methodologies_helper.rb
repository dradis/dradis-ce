module MethodologiesHelper
  def parse_methodology_content(methodology)
    methodology.sections.map do |section|
      content_tag(:h3, section.name) +
      content_tag(:ul, class: 'fa-ul') do
        section.tasks.map do |task|
          content_tag :li, content_tag(:i, nil, class: 'fa fa-check') + ' ' + task.name
        end.join().html_safe
      end
    end.join().html_safe
  end
end
