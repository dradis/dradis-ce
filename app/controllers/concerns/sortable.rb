module Sortable
  extend ActiveSupport::Concern

  def sort
    entity = params[:controller].singularize
    klass = entity.capitalize.constantize

    klass.transaction do
      params[entity].each_with_index do |id, index|
        klass.where(id: id.to_i).update_all({ position: index + 1 })
      end
    end

    head :ok
  end
end
