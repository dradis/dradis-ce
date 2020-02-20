module Dradis::CE::API
  module V1
    class NotesController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_node

      def index
        @notes = @node.notes.all.order('updated_at desc')
      end

      def show
        @note = @node.notes.find(params[:id])
      end

      def create
        @note = @node.notes.build(note_params)
        @note.category ||= Category.default
        if @note.save
          track_created(@note)
          render status: 201, location: node_note_path(@node, @note)
        else
          render_validation_errors(@note)
        end
      end

      def update
        @note = @node.notes.find(params[:id])
        if @note.update_attributes(note_params)
          track_updated(@note)
          render note: @note
        else
          render_validation_errors(@note)
        end
      end

      def destroy
        @note = @node.notes.find(params[:id])
        @note.destroy
        track_destroyed(@note)
        render_successful_destroy_message
      end

      private

      def set_node
        @node = current_project.nodes.find(params[:node_id])
      end

      def note_params
        params.require(:note).permit(:category_id, :text)
      end

    end
  end
end
