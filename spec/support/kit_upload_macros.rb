module KitUploadMacros
  extend ActiveSupport::Concern

  def setup_kit_import
    file = File.new(Rails.root.join('spec', 'fixtures', 'files', 'templates', 'kit.zip'))
    @tmp_dir  = Rails.root.join('tmp', 'rspec')
    FileUtils.mkdir_p @tmp_dir

    # Use a temporary file for the job instead of the original fixture
    FileUtils.cp file.path, @tmp_dir
    @tmp_file = File.new(@tmp_dir.join('kit.zip'))

    ['methodologies', 'notes', 'plugins', 'projects', 'reports'].each do |item|
      conf = Configuration.find_or_initialize_by(name: "admin:paths:templates:#{item}")
      folder = @tmp_dir.join(item)
      conf.value = folder
      conf.save!
      FileUtils.mkdir_p folder
    end

    allow(NoteTemplate).to receive(:pwd).and_return(
      Pathname.new(Configuration.paths_templates_notes)
    )
    allow(Methodology).to receive(:pwd).and_return(
      Pathname.new(Configuration.paths_templates_methodologies)
    )
    allow(ProjectTemplate).to receive(:pwd).and_return(
      Pathname.new(Configuration.paths_templates_projects)
    )
  end

  def cleanup_kit_import
    FileUtils.rm_rf(Dir.glob(Attachment.pwd + '*'))
    FileUtils.rm_rf(Rails.root.join('tmp', 'rspec'))
    Configuration.delete_by('name LIKE ?', 'admin:paths:%')
  end
end
