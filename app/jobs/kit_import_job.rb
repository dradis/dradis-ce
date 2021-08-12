class KitImportJob < ApplicationJob
  REPORT_TEMPLATE_FILE_EXTENSIONS = {
    'excel' => ['xlsm', 'xlsx'],
    'html_export' => ['html.erb'],
    'word' => ['docm', 'docx']
  }

  queue_as :dradis_upload

  rescue_from(StandardError) do |e|
    logger.info "An error ocurred: #{e.message}"
  end

  def perform(file:, logger:, user_id: nil)
    @current_user = user_id ? User.find(user_id) : User.first
    @file = file
    @logger = logger
    @project = nil
    @report_templates_dir = Configuration.paths_templates_reports
    @temporary_dir = Dir.mktmpdir
    @word_rtp = nil

    FileUtils.cp file, temporary_dir
    unzip
    import_methodology_templates
    import_note_templates
    import_plugin_templates
    import_project_package
    import_project_templates
    import_report_template_files
    if defined?(Dradis::Pro)
      import_report_template_properties
      import_rules

      assign_project_rtp
    end

  ensure
    logger.info('Worker process completed.')
    FileUtils.remove_entry temporary_dir
    File.unlink(file) if File.exists?(file)
  end

  private
  attr_reader :current_user, :file, :logger, :report_templates_dir, :temporary_dir

  def assign_project_rtp
    logger.info { 'Assigning RTP to project...' }

    @project.update_attribute :report_template_properties_id, @word_rtp.id if @word_rtp
  end

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

    @project = Project.create(
      name: NamingService.name_project(File.basename(project_package, '.zip'))
    )

    if @project.errors.any?
      logger.info { '  - Project errors: '}
      @project.errors.full_messages.each do |error|
        logger.info { "    - #{error}"}
      end
      return
    end

    @project.assign_owner(current_user)
    logger.info { "  - Importing project: #{@project.name}" }
    importer = Dradis::Plugins::Projects::Upload::Package::Importer.new(
      project_id: @project.id,
      plugin: Dradis::Plugins::Projects::Upload::Package,
      default_user_id: current_user.id
    )
    importer.import(file: project_package)

    logger.info { "  - New Project #{@project.id} created." }
  end

  def import_plugin_templates
    return unless File.directory?("#{temporary_dir}/kit/templates/plugins/")

    logger.info { 'Copying Plugin Manager templates...' }
    import_templates('plugins')
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
      dest = "#{report_templates_dir}/#{plugin}/"
      temp_plugin_path = "#{temporary_dir}/kit/templates/reports/#{plugin}/*"

      # Only allow certain file extensions
      files = Dir[temp_plugin_path].select do |f|
        f.end_with?(*REPORT_TEMPLATE_FILE_EXTENSIONS[plugin])
      end

      FileUtils.mkdir_p(dest)
      FileUtils.cp(files, dest)
    end
  end

  def import_report_template_properties
    logger.info { 'Adding properties to report template files...' }

    (Dradis::Plugins.with_feature(:export) - [
      Dradis::Plugins::CSV::Engine,
      Dradis::Plugins::Projects::Engine,
    ]).each do |plugin|
      Dir.glob(File.join(report_templates_dir, plugin.plugin_name.to_s, '*')) do |template|
        basename = File.basename(template, '.*')
        reports_dir = "#{temporary_dir}/kit/templates/reports"
        default_properties = "#{reports_dir}/#{plugin.plugin_name}/#{basename}.rb"

        if File.exist?(default_properties)
          load default_properties

          # Save this for later to assign to a project
          @word_rtp = ReportTemplateProperties.where(
            plugin_name: 'word',
            template_file: File.basename(template)
          ).first
        else
          ReportTemplateProperties.find_or_initialize_by(
            template_file: File.basename(template)
          ).update!(
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

    Dir.chdir(temporary_dir) do
      Zip::File.open(file) do |zip_file|
        zip_file.each do |entry|
          logger.info "  - #{entry.name}"
          zip_file.extract(entry, nil)
        end
      end
    end
  end
end
