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
  end

  def perform(file_or_folder, logger:, user_id: nil, mapping_options: {})
    @current_user = user_id ? User.find(user_id) : User.first
    @mapping_options = mapping_options
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
      import_mappings_from_kit

      assign_project_rtp if @project
    end

  ensure
    logger.info('Worker process completed.')
    FileUtils.remove_entry working_dir
  end

  private
  attr_reader :current_user, :logger, :mapping_options, :templates_dirs, :working_dir

  def assign_project_rtp
    logger.info { 'Assigning RTP to project...' }

    unless @word_rtp
      logger.info { '  - No report template properties found; skipping.' }
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

  def copy_mappings
    Dradis::Plugins.with_feature(:rtp).each do |integration|
      integration_name = integration.plugin_name.to_s
      old_rtp_id = mapping_options[integration_name]
      next unless old_rtp_id

      files = get_report_template_files(integration_name)

      files.each do |template|
        new_rtp = ReportTemplateProperties.find_by(
          plugin_name: integration_name,
          template_file: File.basename(template)
        )

        next unless new_rtp

        # copy mappings from existing rtp to new rtp
        new_rtp.copy_mappings_from!(old_rtp_id)
      end
    end
  end

  def get_report_template_files(integration)
    temp_integration_path = File.join(working_dir, 'kit', 'templates', 'reports', integration, '*')

    # Only allow certain file extensions
    Dir[temp_integration_path].select do |f|
      f.end_with?(*REPORT_TEMPLATE_FILE_EXTENSIONS[integration])
    end
  end

  def import_mappings_from_kit
    action = mapping_options[:action]
    return if action == :manual

    logger.info { 'Adding Mappings...' }

    if action == :seed
      mappings_seed = "#{working_dir}/kit/mappings_seed.rb"
      load mappings_seed if File.exist?(mappings_seed)
    elsif action == :copy
      copy_mappings
    end
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
      # Deliberately not using NamingService/copy_file here: report template
      # files are copied under their own name (overwriting any existing file
      # of the same name) so the filename stays a stable identity that
      # import_report_template_properties can look up the RTP by. Renaming on
      # collision would break that lookup.
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
