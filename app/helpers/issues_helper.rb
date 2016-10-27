module IssuesHelper
  # ------------------------------------------------------------ Import plugins
  # Takes the output of the ImportPlugin (an array of hashes (with :title,
  # :description, :tags for each record) and creates a new Issue object for
  # each element.
  def issues_from_import_records(records)
    issues = []
    records.each_with_index do |record,index|
      issue = Issue.new do |issue|
        issue.id = index
        if record.is_a?(Dradis::Plugins::Import::Result)
          issue.text = record.description
        else
          issue.text = record.fetch(:description,
                        "#[Title]#\nThis plugin did not provide its results in the expected format.\n\n#[Description]#\nWe expect and array of hashes: [{:title, :description}, ...]")
        end
      end

      if !issue.fields.key?('Title')
        # most likely this is some sort of error, try the record's :title
        if record.is_a?(Dradis::Plugins::Import::Result)
          issue.text << "\n\n#[Title]#\n#{record.title}"
        else
          issue.text << "\n\n#[Title]#\n#{record[:title]}"
        end
      end

      # The content of the entry can come with a Tags field, but the plugin
      # can also set some (e.g. the entry's status - 'Draft', 'Pending')
      if record.tags.any?
        tag_list = record.tags.join(',')
        issue.text << "\n\n#[AddonTags]#\n#{tag_list}"
      end

      issues << issue
    end
    issues
  end

  # Output Bootstrap badges if the issue has any associated tags
  def issue_tags(issue)
    return unless issue.fields.key?('Tags') || issue.fields.key?('AddonTags')

    all_tags = []

    %w{Tags AddonTags}.each do |tag_field|
      next unless issue.fields.key?(tag_field)
      content_tags = issue.fields[tag_field].split(',')
      all_tags << content_tags.map do |tag_name|
        tag = Tag.new(name: tag_name.strip)

        content_tag :span, class: 'badge', style: "background-color: #{tag.color}" do
          h(tag.display_name)
        end
      end
    end

    all_tags.join(' ').html_safe
  end

  # ----------------------------------------------------------- /Import plugins
  def tag_and_name_for(issue)
    if tags = issue.tags
      content_tag :span, class: 'h3-tags' do
        [
          (content_tag :i, nil, class: 'fa fa-tags' ),
          h(get_all_tags(tags))
        ].join(' ').html_safe
      end
    else
      content_tag :span, '(no tag)', class: 'muted'
    end
  end

  # Output a Font Awesome tag with the right color
  def tag_icon_for(issue, css_class=nil)
    options = { class: "fa fa-bug #{css_class if css_class}"}

    if tag = issue.tags.first
      options[:style] = "color: #{tag.color}"
    end
    content_tag :i, nil, options
  end

  # Get all the tags associated with this issue
  def get_all_tags(tags)
    tags.map { |tag|
      tag.display_name
    }.join(', ')
  end
end
