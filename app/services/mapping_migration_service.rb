class MappingMigrationService
  attr_reader :integration_name, :rtp_id, :template_file, :templates_dir, :upload_integrations

  def initialize
    @templates_dir = Configuration.paths_templates_plugins
    @upload_integrations = Dradis::Plugins::with_feature(:upload)
  end

  def call
    upload_integrations.each do |integration|
      @integration_name = integration.plugin_name.to_s
      # for each file, create a mapping for that file name&plugin_name
      # combination, for each RTP in the instance (or nil for CE)
      template_files.each do |template_file|
        @template_file = template_file
        if defined? ReportTemplateProperties
          ReportTemplateProperties.all.each do |rtp|
            @rtp_id = rtp.id
            migrate
          end
        else
          migrate
        end
        # delete the .template files after migrating them to the db
        File.delete(template_file)
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
    ActiveRecord::Base.transaction do
      mapping = create_mapping

      template_fields.each do |field_title, field_content|
        # set source_field by taking the first match to the existing %% syntax
        source_field = field_content.match(/%(?<field>\S*?)%/)
        @source_field =
          if source_field && !source_field['field'].empty?
            source_field['field']
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
    template_content = File.open(template_file).read
    FieldParser.source_to_fields(template_content)
  end

  def template_files
    plugin_templates_dir = File.join(templates_dir, integration_name)
    Dir["#{plugin_templates_dir}/*.template"]
  end

  def update_syntax(field_content)
    # turn the %% syntax into the new
    # '{{ <integration>[was-issue.title] }}' format
    field_content.gsub(/%(\S*?)%/) do |content|
      "{{ #{integration_name}[#{content[1..-2]}] }}"
    end
  end
end
