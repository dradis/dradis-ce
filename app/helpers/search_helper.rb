module SearchHelper
	def search_filter_path(options={})
  	exist_opts = {
    	q: params[:q],
      scope: params[:scope]
    }

  	options = exist_opts.merge(options)
    search_path(options)
	end

  def search_row_path(row)
    path_root = ""
    if row.class == Note
      send(:node_note_path, row.node_id, row.id)
    else
      path_root += "#{row.class.to_s.downcase}_path"
      send(path_root.to_sym, row.id)
    end
  end

  def format_match(row)
    link_value = "Match in #{row.class.to_s} - #{format_value(row)}"
    content_tag :div, class: "search-row" do
      concat link_to link_value, "#", class: "search-match-type"
      concat content_tag :p, "Last updated: " + time_ago_in_words(row.updated_at) + "ago",
        class: "search-updated-ago"
      if not row.class == Node
        concat content_tag(:span, matched_data(row), class: "search-match")
      end
    end
  end

  def matched_data(data)
    if data.class == Node
      data.label
    else
      data.text
    end
  end

  def format_value(row)
    row.class.to_s == "Node" ? row.label : row.title
  end
end
