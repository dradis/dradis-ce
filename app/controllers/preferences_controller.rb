class PreferencesController < AuthenticatedController
  before_action :set_theme

  def update
    if @theme
      current_user.preferences.theme = @theme
      current_user.save!

      render json: { theme: current_user.preferences.theme }
    else
      render json: { error: 'Invalid theme' }, status: :unprocessable_entity
      return
    end
  end

  private

  def preferences_params
    params.require(:preferences).permit(:theme)
  end

  def set_theme
    if UserPreferences::VALID_THEMES.include?(preferences_params[:theme])
      @theme = preferences_params[:theme]
    end
  end
end
