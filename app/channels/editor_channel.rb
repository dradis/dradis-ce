# The Editor Channel is opened when a user navigates to the `Edit` page of an
# Evidence, Issue, or Note. The channel is closed when the user navigates away
# from the `edit` page. When open the channel receives updates from the editor
# and saves them as new revisions of the resource.
class EditorChannel < ApplicationCable::Channel
  include ProjectScopedChannels
  include PaperTrailActivity

  attr_accessor :resource

  def subscribed
    reject and return unless find_resource(params)

    stream_for [current_user, current_project, resource]
  end

  def save(params)
    resource.paper_trail_event = 'auto-save'

    if resource.update_attributes parsed_params(params['data'])
      track_activity(resource, 'auto-save')
    end
  end

  private

  def find_resource(params)
    return unless %w[evidence issue note].include? params['resource_type']
    @resource ||= current_project.send(params['resource_type'].pluralize).find_by id: params['resource_id']
  end

  def parsed_params(data)
    wrapped_params = Rack::Utils.parse_nested_query data
    ActionController::Parameters.
      new(wrapped_params).
      require(@params['resource_type']).
      permit(permissable_params(@params['resource_type']))
  end

  def permissable_params(type)
    case type
    when 'evidence' then %i[author content issue_id node_id]
    when 'issue' then %i[tag_list text]
    when 'note' then %i[category_id text node_id]
    else []
    end
  end
end
