class KitImportJob < ApplicationJob
  queue_as :dradis_upload

  rescue_from(StandardError) do |e|
    logger.info "An error ocurred: #{e.message}"
  end

  def perform(file:, logger:, user_id: nil)
    @current_user = user_id ? User.find(user_id) : User.first
    @file = file
    @logger = logger
    @report_templates_dir = Configuration.paths_templates_reports
    @temporary_dir = Dir.mktmpdir

    FileUtils.cp file, temporary_dir
    unzip
    import_methodology_templates
    import_note_templates
    import_project_package
    import_project_templates
    import_report_template_files
    if defined?(Dradis::Pro)
      import_report_template_properties
      import_rules
    end

  ensure
    logger.info('Worker process completed.')
    FileUtils.remove_entry temporary_dir
  end

  private
  attr_reader :current_user, :file, :logger, :report_templates_dir, :temporary_dir

  def import_methodology_templates
    logger.info { 'Copying methodology templates...' }
    import_templates('methodologies')
  end

  def import_note_templates
    logger.info { 'Copying issue, evidence templates...' }
    import_templates('notes')
  end

  def import_project_package
    logger.info { 'Importing project package...' }

    project_package = Dir.glob("#{temporary_dir}/kit/*.zip").first

    unless project_package
      logger.info { '  - Project package not found...' }
      return
    end

    project = Project.create(name: File.basename(project_package, '.zip'))
    if project.errors.any?
      logger.info { '  - Project errors: '}
      project.errors.full_messages.each do |error|
        logger.info { "    - #{error}"}
      end
      return
    end

    project.assign_owner(current_user)
    logger.info { "  - Importing project: #{project.name}" }
    importer = Dradis::Plugins::Projects::Upload::Package::Importer.new(
      project_id: project.id,
      plugin: Dradis::Plugins::Projects::Upload::Package,
      default_user_id: current_user.id
    )
    importer.import(file: project_package)

    logger.info { "  - New Project #{project.id} created." }
  end

  def import_project_templates
    logger.info { 'Copying project templates...' }
    import_templates('projects')
  end

  def import_report_template_files
    logger.info { 'Copying report template files...' }

    FileUtils.mkdir_p report_templates_dir
    %w{
      excel
      html_export
      word
    }.each do |plugin|
      FileUtils.cp_r(
        "#{temporary_dir}/kit/templates/reports/#{plugin}/.",
        "#{report_templates_dir}/#{plugin}/"
      )
    end
  end

  def import_report_template_properties;end

  def import_rules;end

  def import_templates(template_type)
    FileUtils.cp_r(
      "#{temporary_dir}/kit/templates/#{template_type}/.",
      Configuration.send("paths_templates_#{template_type}")
    )
  end

  def unzip
    logger.info { 'Extracting zip file...' }

    Zip::File.open(file) do |zip_file|
      zip_file.each do |entry|
        dest_path = File.join(temporary_dir, entry.name)
        logger.info "  - #{entry.name}"
        zip_file.extract(entry, dest_path)
      end
    end
  end
end
