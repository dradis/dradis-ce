class PreferencesController < AuthenticatedController
  def update
    theme = params.dig(:preferences, :theme)

    unless UserPreferences::VALID_THEMES.include?(theme)
      render json: { error: 'Invalid theme' }, status: :unprocessable_entity
      return
    end

    current_user.preferences.theme = theme
    current_user.save!

    render json: { theme: current_user.preferences.theme }
  end
end
