class MappingMigrationService
  LEGACY_TEMPLATE_REGEX = /%(\S*?)%/
  attr_reader :integration_name, :rtp_id, :template_file

  def call
    upload_integrations = Dradis::Plugins::with_feature(:upload)

    upload_integrations.each do |integration|
      @integration_name = integration.plugin_name.to_s

      template_files.each do |template_file|
        @template_file = template_file

        rtp_ids = defined?(Dradis::Pro) ? ReportTemplateProperties.ids : [nil]
        rtp_ids.each do |rtp_id|
          @rtp_id = rtp_id
          migrate(rtp_id)
          File.rename template_file, "#{template_file}.legacy"
        end
      end
    end
  end

  private

  def create_mapping
    mapping_source = File.basename(template_file, '.template')
    destination = rtp_id ? "rtp_#{rtp_id}" : nil

    Mapping.find_or_create_by!(
      component: integration_name,
      source: mapping_source,
      destination: destination
    )
  end

  def create_mapping_field(mapping, field_title)
    mapping.mapping_fields.find_or_create_by!(
      source_field: @source_field,
      destination_field: field_title,
      content: @updated_content
    )
  end

  def migrate
    # for each file, create a mapping for the uploader&plugin_name combination
    ActiveRecord::Base.transaction do
      mapping = create_mapping

      template_fields.each do |field_title, field_content|
        # set source_field by taking the first match to the existing %% syntax
        source_field = field_content.match(LEGACY_TEMPLATE_REGEX)
        @source_field =
          if source_field && !source_field[1].empty?
            source_field[1]
          else
            'custom text'
          end
        @updated_content = update_syntax(field_content)

        # create a mapping field for each field in the .template file
        create_mapping_field(mapping, field_title)
      end
    end
  end

  def template_fields
    template_content = File.read(template_file)
    FieldParser.source_to_fields(template_content)
  end

  def template_files
    templates_dir = Configuration.paths_templates_plugins
    plugin_templates_dir = File.join(templates_dir, integration_name)
    Dir["#{plugin_templates_dir}/*.template"]
  end

  def update_syntax(field_content)
    # turn the %% syntax into the new
    # '{{ <integration>[was-issue.title] }}' format
    field_content.gsub(LEGACY_TEMPLATE_REGEX) do |content|
      "{{ #{integration_name}[#{content[1..-2]}] }}"
    end
  end
end
