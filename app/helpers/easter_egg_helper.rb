module EasterEggHelper
  def easter_egg_class
    class_names(
      holiday: holiday?,
      'may-4th': may_4th?
    )
  end

  def easter_egg_logo
    case
    when holiday?
      'holiday/logo_full_small.png'
    when may_4th?
      'may_4th/logo_full_small.png'
    else
      'logo_small.png'
    end
  end

  private

  def holiday?
    Date.today.month == 12
  end

  def may_4th?
    Date.today.month == 5 && Date.today.day == 4
  end
end
