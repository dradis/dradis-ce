require 'rails_helper'

# Remember ProjectTemplate inherits from FileBackedModel which is ActiveModel
# compliant
describe ProjectTemplate do
  subject { ::ProjectTemplate.new }
  it_behaves_like 'ActiveModel'

  before(:each) do
    allow(ProjectTemplate).to receive(:pwd) { Pathname.new('tmp/templates/project') }
  end
  after(:all) do
    FileUtils.rm_rf('tmp/templates/')
  end

  it "has a default .xml extension" do
    expect(ProjectTemplate.extension).to eq('.xml')
  end

  it "auto-generates a filename on save" do
    should be_valid
    expect(subject.save).to be true
    expect(subject.filename).to match(/auto_/)
  end

  it "initializes the internal XML document if no content is provided" do
    expect(subject.doc).to_not be_nil
    expect(subject.doc).to respond_to(:root)
    expect(subject.doc.root).to_not be_nil
    expect(subject.doc.root.name).to eq('dradis-template')
  end

  describe '#name' do
    it "has a name based on the contents of the template" do
      instance = ProjectTemplate.from_file( Rails.root.join('spec/fixtures/files/projects/welcome_project.xml') )
      expect(instance.name).to eq('Welcome project template')
      expect(instance.filename).to eq('welcome_project')
    end

    it "adds a default name if none is provided in the content" do
      expect(subject.name).to_not be_nil
      expect(subject.name).to match(/undefined/i)
      expect(subject.content).to match(/undefined/i)
    end

    it "persists the auto-generated name whens saved to disk" do
      expect(subject.name).to match(/undefined/i)
      expect(subject.save).to be true
      full_path = subject.full_path

      doc = Nokogiri::XML(File.read(full_path))
      expect(doc.at_xpath('/dradis-template/name').text()).to match(/undefined/i)
    end
  end
end
