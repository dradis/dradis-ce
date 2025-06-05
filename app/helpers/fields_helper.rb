module FieldsHelper
  LIQUID_FILTER_REGEX = /{{.*\|+.*}}|{%.*\|.*%}/.freeze

  def has_liquid_filters(value)
    value.match(LIQUID_FILTER_REGEX)
  end
end
