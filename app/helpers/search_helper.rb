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
      byebug
      path_root += "#{row.category.class.to_s.downcase}/#{row.category.id}/"
    end
    path_root += "#{row.class.to_s.downcase}_path"
    send(path_root.to_sym, row.id)
  end

  def format_match(row)
    link_to search_row_path(row) do
      content_tag :p,
        "Match in #{row.class.to_s} - #{format_value(row)}"
    end
  end

  def format_value(row)
    row.class.to_s == "Node" ? row.label : row.title
  end
end
