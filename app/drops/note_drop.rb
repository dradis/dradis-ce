class NoteDrop < BaseDrop
  delegate :text, :title, to: :@record

  def fields
    @fields ||= FieldsDrop.new(@record.fields)
  end
end
