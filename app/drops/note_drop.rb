class NoteDrop < Liquid::Drop
  def initialize(note)
    @note = note
  end

  def title
    @note.title
  end

  def text
    @note.text
  end
end
