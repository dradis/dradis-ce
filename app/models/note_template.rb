# Parse a note template from ./templates/notes/
#
# See:
#   http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/
#   http://asciicasts.com/episodes/219-active-model
#   https://github.com/rails/rails/blob/master/activemodel/lib/active_model/conversion.rb
class NoteTemplate
  include FileBackedModel

  # Tell the FileBackedModel module where to find the files on disk
  set_pwd setting: 'admin:paths:note_templates', default: Rails.root.join('templates','notes').to_s
end