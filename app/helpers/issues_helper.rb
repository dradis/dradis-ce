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

      if record.is_a?(Dradis::Plugins::Import::Result)
        if record.tags.any? && !issue.fields.key?('Tags')
          issue.text << "\n\n#[Tags]#\n#{record.tags.join(',')}"
        end
      elsif record.key?(:tags) && !issue.fields.key?('Tags')
        # TODO: replace with a real tag when implemented
        issue.text << "\n\n#[Tags]#\n#{record[:tags].join(',')}"
      end

      issues << issue
    end
    issues
  end

  # Output Bootstrap badges if the issue has any associated tags
  def issue_tags(issue)
    return unless issue.fields.key?('Tags')

    tags = issue.fields['Tags'].split(',')
    tags.map do |tag|
      badge_css = 'badge'
      badge_css << {
        'public' => ' badge-success',
        'private' => ' badge-warning'
      }[tag]

      content_tag :span, :class => badge_css do
        tag
      end
    end.join.html_safe
  end

  # ----------------------------------------------------------- /Import plugins
  def tag_and_name_for(issue)
    if tag = issue.tags.first
      content_tag :span, style: "color: #{tag.color}" do
        [
          tag_icon_for(issue),
          h(tag.display_name)
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
end
