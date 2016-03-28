module SearchHelper
	def search_filter_path(options={})
  	exist_opts = {
    	q: params[:q],
      scope: params[:scope]
    }

  	options = exist_opts.merge(options)
    search_path(options)
	end
end
