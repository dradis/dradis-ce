class UserPreferences
  module Theme
    VALID_THEMES = %w[auto dark light].freeze

    def theme_or_default
      theme || 'auto'
    end

    def valid_theme?
      VALID_THEMES.include?(theme) || theme.nil?
    end
  end
end
