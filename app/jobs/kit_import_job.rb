class KitImportJob < ApplicationJob
  REPORT_TEMPLATE_FILE_EXTENSIONS = {
    'excel' => ['xlsm', 'xlsx'],
    'html_export' => ['html.erb'],
    'word' => ['docm', 'docx']
  }
  TEMPLATE_TYPES = %w{ methodologies notes projects reports }

  queue_as :dradis_upload

  rescue_from(StandardError) do |e|
    logger.info "An error occurred: #{e.message}"
    logger.debug e.backtrace.join("\n")
    # The import Log only streams to the in-browser console; also surface the
    # failure on the Rails log (stdout / log files) so it's visible on the server.
    Rails.logger.error("KitImportJob failed: #{e.full_message}")
  end

  def perform(file_or_folder, logger:, user_id: nil)
    @current_user = user_id ? User.find(user_id) : User.first
    @logger = logger
    @project = nil
    @templates_dirs = TEMPLATE_TYPES.map do |template_type|
      [
        template_type,
        Pathname.new(Configuration.send("paths_templates_#{template_type}"))
      ]
    end.to_h
    @working_dir = Dir.mktmpdir
    @word_rtp = nil

    copy_kit_to_working_dir(file_or_folder)

    import_methodology_templates
    import_note_templates
    import_project_package
    import_project_templates
    import_report_template_files

    if defined?(Dradis::Pro)
      import_report_template_properties
      import_rules
      import_mappings

      assign_project_rtp if @project
    end

  ensure
    logger.info('Worker process completed.')
    FileUtils.remove_entry working_dir
  end

  private
  attr_reader :current_user, :logger, :templates_dirs, :working_dir

  def assign_project_rtp
    logger.info { 'Assigning RTP to project...' }

    unless @word_rtp
      logger.info { '  - No report template properties found; skipping.' }
      Rails.logger.warn("KitImportJob: no word RTP found for project #{@project.id}; skipping RTP assignment")
      return
    end

    # update! (not update_attribute) so a failed write raises and is logged by
    # rescue_from rather than silently returning false.
    @project.update!(report_template_properties_id: @word_rtp.id)
  end

  def copy_file(file, destination)
    return unless File.file?(file)

    file_name = NamingService.name_file(
      original_filename: File.basename(file),
      pathname: destination
    )

    FileUtils.cp(file, "#{destination}/#{file_name}")
  end

  def copy_kit_to_working_dir(source)
    if File.file?(source)
      FileUtils.cp source, working_dir
      unzip(source)
    else
      # We need the folder to end in /. so FileUtils.cp_r copies the contents
      # and not the container folder.
      folder = File.join(source, '.')
      FileUtils.cp_r folder, working_dir
    end
  end

  def get_report_template_files(integration)
    temp_integration_path = File.join(working_dir, 'kit', 'templates', 'reports', integration, '*')

    # Only allow certain file extensions
    Dir[temp_integration_path].select do |f|
      f.end_with?(*REPORT_TEMPLATE_FILE_EXTENSIONS[integration])
    end
  end

  def import_mappings
    logger.info { 'Adding Mappings...' }
    mappings_seed = "#{working_dir}/kit/mappings_seed.rb"
    load mappings_seed if File.exist?(mappings_seed)
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

    project_package = Dir.glob("#{working_dir}/kit/*.zip").first

    unless project_package
      logger.info { '  - Project package not found...' }
      return
    end

    @project = Project.create(
      name: NamingService.name_project(File.basename(project_package, '.zip').titleize)
    )

    if @project.errors.any?
      logger.info { '  - Project errors: ' }
      @project.errors.full_messages.each do |error|
        logger.info { "    - #{error}" }
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

  def import_project_templates
    logger.info { 'Copying project templates...' }
    import_templates('projects')
  end

  def import_report_template_files
    logger.info { 'Copying report template files...' }

    FileUtils.mkdir_p templates_dirs['reports']
    %w{
      excel
      html_export
      word
    }.each do |plugin|
      dest = "#{templates_dirs['reports']}/#{plugin}/"
      files = get_report_template_files(plugin)

      FileUtils.mkdir_p(dest)
      FileUtils.cp(files, dest)
    end
  end

  def import_report_template_properties
    logger.info { 'Adding properties to report template files...' }

    Dradis::Plugins.with_feature(:rtp).each do |plugin|
      plugin_name = plugin.plugin_name.to_s

      # Iterate the kit's own template files (not the whole instance reports
      # directory) so we only attach properties to templates from this kit.
      get_report_template_files(plugin_name).each do |template|
        template_file = File.basename(template)
        basename = File.basename(template, '.*')
        default_properties = File.join(File.dirname(template), "#{basename}.rb")

        rtp =
          if File.exist?(default_properties)
            load default_properties
            ReportTemplateProperties.find_by(
              plugin_name: plugin_name,
              template_file: template_file
            )
          else
            ReportTemplateProperties.find_or_initialize_by(
              template_file: template_file
            ).tap { |report| report.update!(plugin_name: plugin_name) }
          end

        # Save the word RTP so the imported project can be linked to it later,
        # whether or not the template shipped a properties seed. Only the word
        # plugin may set this, so excel/html_export templates can't clobber it.
        @word_rtp = rtp if plugin_name == 'word' && rtp

        if plugin_name == 'word' && rtp.nil?
          Rails.logger.warn("KitImportJob: word template #{template_file} produced no RTP")
        end
      end
    end
  end

  def import_rules
    logger.info { 'Adding Rules Engine rules...' }
    rules_seed = "#{working_dir}/kit/rules_seed.rb"
    load rules_seed if File.exist?(rules_seed)
  end

  def import_templates(template_type)
    kit_template_dir = "#{working_dir}/kit/templates/#{template_type}"
    return unless Dir.exist?(kit_template_dir)

    destination = templates_dirs[template_type]
    FileUtils.mkdir_p(destination) unless File.exist?(destination)

    Dir["#{kit_template_dir}/*"].each do |file|
      copy_file(file, destination)
    end
  end

  def unzip(file)
    logger.info { 'Extracting zip file...' }

    Dir.chdir(working_dir) do
      Zip::File.open(file) do |zip_file|
        zip_file.each do |entry|
          logger.info "  - #{entry.name}"
          zip_file.extract(entry, nil)
        end
      end
    end
  end
end
