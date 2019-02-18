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
    NoteTemplate.new(name: 'Basic fields', content: "#[Title]#\n\n\n#[Description]#\n\n\n#[Recommendation]#\n\n").save
  end



  # ----------------------------------------------------------------- Methodology
  if !Methodology.pwd.exist?
    Methodology.pwd.mkpath
    xml_blob =<<-EOX
    <?xml version="1.0"?>
    <methodology>
      <name>Simple OWASP checklist</name>
      <sections>
        <section>
          <name>OWASP Top 10</name>
          <tasks>
            <task>A1:2017 - Injection</task>
            <task>A2:2017 - Broken Authentication</task>
            <task>A3:2017 - Sensitive Data Exchange</task>
            <task>A4:2017 - XML External Entities (XXE)</task>
            <task>A5:2017 - Broken Access Control</task>
            <task>A6:2017 - Security Misconfiguration</task>
            <task>A7:2017 - Cross-Site Scripting (XSS)</task>
            <task>A8:2017 - Insecure Deserialization</task>
            <task>A9:2017 - Using Components with Known Vulnerabilities</task>
            <task>A10:2017 - Insufficiend Logging & Monitoring</task>
          </tasks>
        </section>
        <section>
          <name>A1:2017 - Injection</name>
          <tasks>
            <task>Check for SQL injection</task>
            <task>Check for LDAP injection</task>
            <task>Check for XPath injection</task>
            <task>Check for NoSQL injection</task>
            <task>Check for OS command injection</task>
            <task>Check for XML injection</task>
            <task>Check for SMTP headers injection</task>
            <task>Check for ORM queries injection</task>
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
