module Sortable
  extend ActiveSupport::Concern

  def sort
    klass = sort_params[:controller].classify.constantize

    klass.transaction do
      sort_params[:sortable_ids].each_with_index do |id, index|
        klass.where(id: id.to_i).update_all({ position: index + 1 })
      end
    end

    head :ok
  end

  private

  def sort_params
    params.permit(:controller, sortable_ids: [])
  end
end
