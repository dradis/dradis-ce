module EasterEggHelper
  def easter_egg_class
    class_names(
      december: december?,
      'may-4th': may_4th?
    )
  end

  def easter_egg_logo
    case
    when december?
      'december/logo_full_small.png'
    when may_4th?
      'may_4th/logo_full_small.png'
    else
      nil
    end
  end

  private

  def december?
    Date.today.month == 12
  end

  def may_4th?
    Date.today.month == 5 && Date.today.day == 4
  end
end
