class PreferencesController < AuthenticatedController
  before_action :set_theme

  def update
    unless UserPreferences::VALID_THEMES.include?(@theme) || @theme.nil?
      render json: { error: 'Invalid theme' }, status: :unprocessable_entity
      return
    end

    current_user.preferences.theme = @theme
    current_user.save!

    render json: { theme: current_user.preferences.theme }
  end

  private

  def preferences_params
    params.require(:preferences).permit(:theme)
  end

  def set_theme
    @theme = preferences_params[:theme]
  end
end
