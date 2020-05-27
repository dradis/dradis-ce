class TourRegistry
  TOURS = {
    projects_show: Gem::Version.new('3.17.0')
  }

  def self.display_for?(tour, user)
    latest_version  = TOURS.fetch(tour)
    preference_name = "last_#{tour}".to_sym
    latest_version > Gem::Version.new(user.preferences.send(preference_name) || '0')
  end

  def self.displayed_for!(tour, user)
    preference_name = "last_#{tour}="
    user.preferences.send(preference_name, TOURS.fetch(tour).to_s)
    user.save
  end
end
