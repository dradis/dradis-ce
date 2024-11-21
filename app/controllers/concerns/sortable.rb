module Sortable
  extend ActiveSupport::Concern

  def sort
    ActiveRecord::Base.transaction do
      sort_params[:sortable_ids].each_with_index do |id, index|
        sortable_records.where(id: id.to_i).update_all({ position: index + 1, updated_at: Time.now })
      end
    end

    head :ok
  end

  private

  def sort_params
    params.permit(sortable_ids: [])
  end

  def sortable_records
    # to be implemented by each controller
    raise NotImplementedError
  end
end
