  # class MappingCreator
  # LEGACY_FIELDS_REGEX = /%(\S+?)%/
  # LEGACY_MAPPING_REFERENCE = {
  #   'burp' => {
  #     'html_evidence' => 'html_evidence',
  #     'html_issue' => 'issue',
  #     'xml_evidence' => 'evidence',
  #     'xml_issue' => 'issue'
  #   },
  #   'qualys' => {
  #     'asset_evidence' => 'asset-evidence',
  #     'asset_issue' => 'asset-issue',
  #     'vuln_evidence' => 'evidence',
  #     'vuln_element' => 'element',
  #     'was_evidence' => 'was-evidence',
  #     'was_issue' => 'was-issue'
  #   }
  # }

  # Rails.application.reloader.to_prepare do
  #   if (ActiveRecord::Base.connection rescue false) && Configuration.table_exists? && Configuration.paths_templates.exist?
  #     upload_integrations.each do |integration|
  #       @integration_name = integration.plugin_name.to_s
  #       set_integration_template_dirs

  #       if integration.uploaders.count > 1
  #         migrate_multiple_upload_integration(@integration_name)
  #       else
  #         integration_template_files = Dir["#{@integration_templates_dir}/*.template"]
  #         integration_template_files.each do |template_file|
  #           mapping_source = File.basename(template_file, '.template')
  #           # create a mapping & mapping_fields for each field in the file
  #           migrate(template_file, mapping_source)
  #         end
  #       end
  #     end
  #   end
  # end

  # def create_mapping(mapping_source)
  #   destination = @rtp_id ? "rtp_#{@rtp_id}" : nil

  #   Mapping.find_or_create_by!(
  #     component: @integration_name,
  #     source: mapping_source,
  #     destination: destination
  #   )
  # end

  # def create_mapping_fields(mapping, template_file)
  #   template_fields = parse_template_fields(template_file)

  #   # create a mapping_field for each field in the .template file
  #   template_fields.each do |field_title, field_content|
  #     # set source_field by taking the first match to the existing %% syntax
  #     source_field = field_content.match(LEGACY_FIELDS_REGEX)
  #     source_field = source_field ? source_field[1] : 'custom text'

  #     updated_content = update_syntax(field_content)

  #     mapping.mapping_fields.find_or_create_by!(
  #       source_field: source_field,
  #       destination_field: field_title,
  #       content: updated_content
  #     )
  #   end
  # end

  # def migrate(template_file, mapping_source)
  #   rtp_ids = defined?(Dradis::Pro) ? ReportTemplateProperties.ids : [nil]
  #   rtp_ids.each do |rtp_id|
  #     @rtp_id = rtp_id

  #     ActiveRecord::Base.transaction do
  #       mapping = create_mapping(mapping_source)
  #       create_mapping_fields(mapping, template_file)
  #     end
  #   end
  #   File.rename template_file, "#{template_file}.legacy"
  # end

  # previously our integrations with multiple uploaders (Burp, Qualys) had inconsistent
  # template names (some included the uploader, some didn't ex. burp issue vs html_evidence)
  # they have been renamed to follow a consistent 'uploader_entity' structure, but
  # in order to migrate the old templates to the db with the new names as the source
  # we need to reference an object in the integration that maps the new name to the old one
  # def migrate_multiple_upload_integration(integration)
  #   byebug
  #   LEGACY_MAPPING_REFERENCE[integration].each do |source_field, legacy_template_name|
  #     template_file = Dir["#{@integration_templates_dir}/#{legacy_template_name}.template*"]
  #     if template_file.any? { |file| File.exist?(file) }
  #       migrate(template_file[0], source_field)
  #     end
  #   end
  # end

  # def parse_template_fields(template_file)
  #   template_content = File.read(template_file)
  #   FieldParser.source_to_fields(template_content)
  # end

  # def set_integration_template_dirs
  #   @templates_dir = Configuration.paths_templates_plugins
  #   @integration_templates_dir = File.join(@templates_dir, @integration_name)
  # end

  def update_syntax(field_content)
    # turn the %% syntax into the new
    # '{{ <integration>[was-issue.title] }}' format
    field_content.gsub(LEGACY_FIELDS_REGEX) do |content|
      "{{ #{@integration_name}[#{content[1..-2]}] }}"
    end
  end

  def upload_integrations
    upload_integrations = Dradis::Plugins::with_feature(:upload)
    upload_integrations - [
      Dradis::Plugins::Projects::Engine, Dradis::Plugins::CSV::Engine
    ]
  end
# end
