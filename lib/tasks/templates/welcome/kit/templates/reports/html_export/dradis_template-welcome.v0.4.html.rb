ReportTemplateProperties.create_from_hash!(
  definition_file: File.basename(__FILE__, '.html.rb'),
  # plugin_name: 'excel',
  # plugin_name: 'word',
  plugin_name: 'html_export',
  content_block_fields: {
    'Conclusions' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Conclusions'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Appendix' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Appendix'},
      {name: 'Description', type: 'string', values: nil}
    ]
  },
  document_properties: [
    'dradis.project',
    'dradis.author',
    'dradis.client',
    'dradis.version'
  ],
  evidence_fields: [
    {name: 'Location', type: 'string', values: nil},
    {name: 'Output', type: 'string', values: nil}
  ],
  issue_fields: [
    {name: 'Title', type: 'string', values: nil},
    {name: 'CVSSv4.BaseScore', type: 'number', values: nil},
    {name: 'CVSSv4.BaseVector', type: 'string', values: nil},
    {name: 'Type', type: 'string', values: "Internal\nExternal"},
    {name: 'Description', type: 'string', values: nil},
    {name: 'Solution', type: 'string', values: nil},
    {name: 'References', type: 'string', values: nil}
  ],
  sort_field: 'CVSSv4.BaseScore'
)
