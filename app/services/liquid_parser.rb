class LiquidParser
  attr_accessor :field, :project, :record

  def initialize(field: nil, project:, record:)
    @field = field
    @project = project
    @record = record
  end

  def parse
    @output ||= HTML::Pipeline::Dradis::LiquidFilter.call(
      value,
      liquid_assigns: liquid_assigns
    ).strip
  end

  private

  def value
    if field
      record.fields[field]
    else
      record.content
    end
  end

  def liquid_assigns
    project_assigns = LiquidCachedAssigns.new(project: project)

    project_assigns.merge(record_assigns)
  end

  def record_assigns
    record_class = record.class.to_s
    drop_class = "#{record_class}Drop".constantize

    { record_class.underscore => drop_class.new(record) }
  end
end
