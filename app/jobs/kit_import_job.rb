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

    if defined?(Dradis::Pro)
      project = Project.create(name: File.basename(project_package, '.zip'))
      if project.errors.any?
        logger.info { '  - Project errors: '}
        project.errors.full_messages.each do |error|
          logger.info { "    - #{error}"}
        end
        return
      end
      project.assign_owner(current_user)
    else
      project = Project.new
    end

    logger.info { "  - Importing project: #{project.name}" }
    importer = Dradis::Plugins::Projects::Upload::Package::Importer.new(
      project_id: project.id,
      plugin: Dradis::Plugins::Projects::Upload::Package,
      default_user_id: current_user.try(:id)
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
      reports_dir = "#{temporary_dir}/kit/templates/reports/#{plugin}"
      FileUtils.cp_r(
        "#{reports_dir}/.",
        "#{report_templates_dir}/#{plugin}/"
      ) if File.exist?(reports_dir)
    end
  end

  def import_report_template_properties
    logger.info { 'Adding properties to report template files...' }

    (Dradis::Plugins.with_feature(:export) - [
      Dradis::Plugins::CSV::Engine,
      Dradis::Plugins::Projects::Engine,
    ]).each do |plugin|
      Dir.glob(File.join(report_templates_dir, plugin.plugin_name.to_s, '*')) do |template|
        reports_dir = "#{temporary_dir}/kit/templates/reports"
        basename = File.basename(template, '.*')
        default_properties = "#{reports_dir}/#{plugin.plugin_name}/#{basename}.rb"
        if File.exist?(default_properties)
          load default_properties
        else
          ReportTemplateProperties.find_or_initialize_by(
            template_file: File.basename(template),
          ).update_attributes!(
            plugin_name: plugin.plugin_name
          )
        end
      end
    end
  end

  def import_rules
    logger.info { 'Adding Rules Engine rules...' }
    rules_seed = "#{temporary_dir}/kit/rules_seed.rb"
    load rules_seed if File.exist?(rules_seed)
  end

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
