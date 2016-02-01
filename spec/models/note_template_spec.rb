require 'spec_helper'

# Remember NoteTemplate inherits from FileBackedModel which is ActiveModel
# compliant
describe NoteTemplate do
  subject { ::NoteTemplate.new }
  it_behaves_like 'ActiveModel'

  before(:each) do
    NoteTemplate.stub(:pwd) { Pathname.new('tmp/templates/notes') }
  end
  after(:all) do
    FileUtils.rm_rf('tmp/templates/')
  end

  it "defines a class .pwd() method" do
    NoteTemplate::methods.should include(:pwd)
    NoteTemplate.pwd.should respond_to('join')
  end

  it "provides a find(id) method" do
    NoteTemplate::methods.should include(:find)

    # Handle non-existing
    lambda { NoteTemplate.find('none_existent') }.should raise_error()

    # Handle existing templates
    FileUtils.mkdir_p(NoteTemplate.pwd) unless File.exists?(NoteTemplate.pwd)
    test_file = NoteTemplate.pwd.join('foo.txt')
    File.open( test_file, 'w' ){ |f| f << 'bar' }
    lambda { NoteTemplate.find('foo') }.should_not raise_error()
    nt = NoteTemplate.find('foo')
    nt.content.should eq('bar')
    File.delete(test_file)
  end

  it "validates presence of filename" do
    nt = NoteTemplate.new(:content => 'foobar')
    nt.should_not be_valid()

    nt.filename = 'tpl_test'
    nt.should be_valid()

    nt.filename = nil
    nt.should_not be_valid()

    nt.name = 'My template'
    nt.should be_valid()
  end

  it "doesn't accept bad characters in the name" do
    nt = NoteTemplate.new( :name => '../../../../../etc' )
    nt.should_not be_valid()

    nt.name = "foo"
    nt.should be_valid()

    nt.name = 'bar.txt'
    nt.should_not be_valid()
  end

  it "needs to be valid before it is saved on disk" do
    nt = NoteTemplate.new
    nt.should_not be_valid()
    nt.save.should be_false
  end

  pending "prevents a template from being overwritten"

  it "creates the templates dir if it doesn't exist when saving" do
    FileUtils.rm_rf(NoteTemplate.pwd) if File.exists?(NoteTemplate.pwd)

    nt = NoteTemplate.new(:name => 'New Spec Template', :content => 'Simple note content: *kapow*!')
    nt.save.should be_true

    new_note_template = NoteTemplate.pwd.join('new_spec_template.txt')
    File.exists?(NoteTemplate.pwd).should be_true
    File.exists?(new_note_template).should be_true
    File.read(new_note_template).should eq('Simple note content: *kapow*!')
    File.delete(new_note_template)
  end


  it "saves the template contents when saving the instance" do
    nt = NoteTemplate.new(:content => 'FooBar', :filename => 'tpl_test')
    nt.save.should be_true
    filename = NoteTemplate.pwd.join('tpl_test.txt')
    File.exists?(filename).should be_true
    File.read(filename).should eq('FooBar')
    File.delete(filename)
  end

  it "deletes file from disk on destroy" do
    nt = NoteTemplate.new(:content => 'FooBar', :filename => 'tpl_test')
    nt.save

    filename = NoteTemplate.pwd.join('tpl_test.txt')
    File.exists?(filename).should be_true
    nt.should respond_to('destroy')
    nt.should respond_to('delete')
    nt.destroy
    File.exists?(filename).should be_false
  end

  it "destroy() works even if the file doesn't exist any more or never existed" do
    nt = NoteTemplate.new(:filename => 'foobar')
    lambda { nt.destroy }.should_not raise_error

    FileUtils.mkdir_p(NoteTemplate.pwd) unless File.exists?(NoteTemplate.pwd)
    filename = NoteTemplate.pwd.join('foobar.txt')
    File.open(filename,'w'){ |f| f<<'barfoo' }

    nt = NoteTemplate.from_file(filename)
    nt.content.should eq('barfoo')
    File.delete(filename)

    lambda { nt.destroy }.should_not raise_error
  end
end
