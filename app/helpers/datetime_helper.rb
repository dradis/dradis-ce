module DatetimeHelper
  def self.parse(date_param)
    return nil unless date_param.present?

    Date.parse(date_param).strftime("%Y/%d/%m")
  end
end