class BaseDrop < Liquid::Drop
  delegate :id, to: :@record

  def initialize(record)
    @record = record
  end
end
