module Dradis::Plugins::Echo
  module PromptsHelper
    def prompt_icons_collection
      Prompt::LABELS.map.with_index do |label, index|
        icon = Prompt::ICONS[index]
        [label, icon, { 'data-combobox-option-icon': "fa-solid #{icon}" }]
      end
    end
  end
end
