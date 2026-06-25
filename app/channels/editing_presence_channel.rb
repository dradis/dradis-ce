class EditingPresenceChannel < ApplicationCable::Channel
  def subscribed
    @record_type = params[:record_type]
    @record_id = params[:record_id]

    stream_from stream_name

    EditingSession.find_or_create_by!(
      user: current_user,
      record_type: @record_type,
      record_id: @record_id
    )
  end

  def unsubscribed
    EditingSession.where(
      user: current_user,
      record_type: @record_type,
      record_id: @record_id
    ).destroy_all
  end

  private

  def stream_name
    "editing:#{@record_type}:#{@record_id}"
  end
end
