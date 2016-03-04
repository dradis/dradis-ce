# Be sure to restart your server when you modify this file.

# If there are no Note or Methodology templates, we create some so the user at
# least can see an entry / how they look / how they work.


# Make sure this is not the first time we're init'ing the app via rake
# db:migrate. If we don't have a `configurations` table, we can't know
# where the templates are stored!
if Configuration.table_exists?

  # --------------------------------------------------------------- Note template
  if !NoteTemplate.pwd.exist?
    NoteTemplate.pwd.mkpath
    NoteTemplate.new(name: 'Basic fields', content: "#[Title]#\n\n\n#[Description]#\n\n").save
  end



  # ----------------------------------------------------------------- Methodology
  if !Methodology.pwd.exist?
    Methodology.pwd.mkpath
    xml_blob =<<-EOX
    <?xml version="1.0"?>
    <methodology>
      <name>New checklist</name>
      <sections>
        <section>
          <name>Section #1</name>
          <tasks>
            <task>Task #1.1</task>
            <task>Task #1.2</task>
          </tasks>
        </section>
        <section>
          <name>Section #2</name>
          <tasks>
            <task>Task #2.1</task>
          </tasks>
        </section>
      </sections>
    </methodology>
    EOX
    File.open(Methodology.pwd.join('sample.xml'), 'w') do |f|
      f << xml_blob
    end
  end

end
