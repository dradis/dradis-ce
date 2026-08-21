class UserPreferences
  module Theme
    DEFAULT_THEME = 'auto'.freeze
    VALID_THEMES = %w[auto dark light].freeze

    def valid_theme?
      VALID_THEMES.include?(theme)
    end
  end
end
