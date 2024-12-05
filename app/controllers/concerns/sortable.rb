module Sortable
  extend ActiveSupport::Concern

  def sort
    klass = sortable_records[:klass]

    ActiveRecord::Base.transaction do
      sort_params[:sorted_ids].each_with_index do |id, index|
        id = id.to_i

        if sortable_records[:ids].include?(id)
          klass.update(id, position: index + 1)
        end
      end
    end

    head :ok
  end

  private

  def sort_params
    params.permit(sorted_ids: [])
  end

  def sortable_records
    # to be implemented by each controller
    raise NotImplementedError
  end
end
