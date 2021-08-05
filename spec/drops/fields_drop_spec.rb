require 'rails_helper'

describe FieldsDrop do
  subject { described_class.new(@params) }

  it 'returns the record\'s fields' do
    issue = create(:issue, text: "#[Title]#\nIssue #1\n\n#[CVSS]#\n4.5\n\n")
    @params = issue.fields

    expect(subject.title).to eq('Issue #1')
    expect(subject.cvss).to eq('4.5')
  end

  it 'returns a record\'s fields with spaces and dot in name' do
    issue = create(:issue, text: "#[CVSS.BaseScore]#\n4.5\n\n#[Field Space]#\ntest\n\n")
    @params = issue.fields

    expect(subject.cvss_basescore).to eq('4.5')
    expect(subject.field_space).to eq('test')
  end

  it 'throws an error if the field is missing' do
    issue = create(:issue, text: "#[Title]#\nIssue #1\n\n")
    @params = issue.fields

    expect{ subject.missing_field }.to raise_error(NoMethodError)
  end

  it 'returns the fields in the drop' do
    issue = create(:issue, text: "#[Title]#\nIssue #1\n\n#[CVSS]#\n4.5\n\n")
    drop = IssueDrop.new(issue)

    expect(drop.fields.title).to eq('Issue #1')
    expect(drop.fields.cvss).to eq('4.5')
  end
end
