# The Editor Channel is opened when a user navigates to the edit page of an
# Evidence, Issue, Note, or Card. The subscription is closed when the user
# navigates away from the edit page. An open subscription receives updates
# from the editor and saves them as new revisions of the resource. The channel
# then broadcasts the resource's updated_at field back to the subscriber so
# the form can update the original_updated_at field used for conflict
# resolution. Although multiple users may be subscribed the channel broadcasts
# messages out with a user scope. This means users will not receive live updates
# of changes from other users.
class EditorChannel < ApplicationCable::Channel
  include ProjectScopedChannels

  attr_accessor :resource

  def subscribed
    reject and return unless find_resource

    stream_for [current_user, current_project, resource]
  end

  def save(params)
    resource.paper_trail_event = RevisionTracking::REVISABLE_EVENTS[:autosave]

    if resource.update_attributes resource_params(params)
      RevisionCollapser.collapse(resource, RevisionTracking::REVISABLE_EVENTS[:autosave])
      self.class.broadcast_to([current_user, current_project, resource], resource.reload.updated_at.to_i)
    end
  end

  private

  def find_resource
    case params['resource_type']
    when 'card'
      authorized_list_ids = List.where(board_id: current_project.boards.select(:id)).select(:id)
      @resource = Card.find_by(id: @params['resource_id'], list_id: authorized_list_ids)
    when 'evidence'
      @resource = current_project.evidence.find_by id: @params['resource_id']
    when 'issue'
      @resource = current_project.issues.find_by id: @params['resource_id']
    when 'note'
      @resource = current_project.notes.find_by id: @params['resource_id']
    end
  end

  def resource_params(data)
    permitted_params = case @params['resource_type']
                       when 'card' then [:name, :description, :due_date, assignee_ids: []]
                       when 'evidence' then %i[author content issue_id node_id]
                       when 'issue' then %i[tag_list text]
                       when 'note' then %i[category_id text node_id]
                       else []
                       end

    # Nest the params like in controllers
    nested_params = Rack::Utils.parse_nested_query(data['data'])
    ActionController::Parameters.new(nested_params).
      require(@params['resource_type']).
      permit(permitted_params)
  end
end
