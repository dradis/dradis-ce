# Be sure to restart your server when you modify this file.

# If there are no Note or Methodology templates, we create some so the user at
# least can see an entry / how they look / how they work.


# --------------------------------------------------------------- Note template
if !NoteTemplate.pwd.exist?
  NoteTemplate.pwd.mkpath
  NoteTemplate.new(name: 'Basic fields', content: "#[Title]#\n\n\n#[Description]#\n\n").save
end



# ----------------------------------------------------------------- Methodology
if !Methodology.pwd.exist?
  Methodology.pwd.mkpath
  %w{sample.xml}.each do |file|
    source_file      = Rails.root.join('spec', 'fixtures', 'files', 'methodologies', file)
    destination_file = Methodology.pwd.join(file)
    FileUtils.cp(source_file, destination_file)
  end
end
