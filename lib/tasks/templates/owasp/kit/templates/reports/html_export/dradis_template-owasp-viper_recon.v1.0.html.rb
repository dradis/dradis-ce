ReportTemplateProperties.create_from_hash!(
  definition_file: File.basename(__FILE__, '.html.rb'),
  plugin_name: 'html_export',
  content_block_fields: {
    'Document Control' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Document Control'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Engagement Overview' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Engagement Overview'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Key Findings' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Key Findings'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Risk Posture' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Risk Posture'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Recommendations' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Recommendations'},
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
    'dradis.client',
    'dradis.author',
    'dradis.version',
    'dradis.start_date',
    'dradis.end_date',
    'dradis.overall_risk_level'
  ],
  evidence_fields: [
    {name: 'Output', type: 'string', values: nil},
    {name: 'Show', type: 'string', values: "Yes\nNo"}
  ],
  issue_fields: [
    {name: 'Title', type: 'string', values: nil},
    {name: 'Impact', type: 'string', values: "Very High\nHigh\nModerate\nLow\nVery Low"},
    {name: 'Likelihood', type: 'string', values: "Very High\nHigh\nModerate\nLow\nVery Low"},
    {name: 'OWASP Domain', type: 'string', values: "Web\nAPI\nMobile"},
    {name: 'OWASP Top 10', type: 'string', values: nil},
    {name: 'Description Long', type: 'string', values: nil},
    {name: 'Description Short', type: 'string', values: nil},
    {name: 'Remediation Status', type: 'string', values: "Open\nIn Progress\nRemediated\nPartially Remediated\nAccepted Risk"},
    {name: 'References', type: 'string', values: nil},
    {name: 'Risk Score', type: 'number', values: nil}
  ],
  sort_fields: ['Risk Score']
)
