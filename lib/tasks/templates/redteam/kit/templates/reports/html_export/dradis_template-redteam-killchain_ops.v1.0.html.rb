ReportTemplateProperties.create_from_hash!(
  definition_file: File.basename(__FILE__, '.html.rb'),
  plugin_name: 'html_export',
  content_block_fields: {
    'Rules of Engagement' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Rules of Engagement'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Executive Summary' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Executive Summary'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Attack Narrative' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Attack Narrative'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Key Findings' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Key Findings'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Detection Analysis' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Detection Analysis'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Recommendation' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Recommendation'},
      {name: 'Description', type: 'string', values: nil}
    ],
    'Appendix' => [
      {name: 'Title', type: 'string', values: nil},
      {name: 'Type', type: 'string', values: 'Appendix'},
      {name: 'Description', type: 'string', values: nil}
    ]
  },
  document_properties: [
    'dradis.client',
    'dradis.start_date',
    'dradis.end_date',
    'dradis.prepared_by',
    'dradis.version'
  ],
  evidence_fields: [
    {name: 'Output', type: 'string', values: nil},
    {name: 'Timestamp', type: 'string', values: nil}
  ],
  issue_fields: [
    {name: 'Title', type: 'string', values: nil},
    {name: 'Severity', type: 'string', values: "Critical\nHigh\nMedium\nLow\nInfo"},
    {name: 'Tactic', type: 'string', values: "Collection\nCommand and Control\nCredential Access\nDefense Evasion\nDiscovery\nExecution\nExfiltration\nImpact\nInitial Access\nLateral Movement\nPersistence\nPrivilege Escalation\nReconnaissance\nResource Development\nRemove Service Effects\nNetwork Effects\nEvasion\nImpair Process Control\nInhibit Response Function"},
    {name: 'Technique', type: 'string', values: nil},
    {name: 'Technique ID', type: 'string', values: nil},
    {name: 'Detection', type: 'string', values: "Undetected\nDetected\nPartially Detected"},
    {name: 'Description', type: 'string', values: nil},
    {name: 'Attack Narrative', type: 'string', values: nil},
    {name: 'Business Impact', type: 'string', values: nil},
    {name: 'Recommendations', type: 'string', values: nil},
    {name: 'References', type: 'string', values: nil}
  ]
)
