class EditorChannel < ApplicationCable::Channel
  attr_accessor :current_project, :resource

  def subscribed
    stream_from "editor_#{params[:project_id]}_#{params[:resource_type]}:#{params[:resource_id]}"

    @current_project = Project.find(params[:project_id])
    @resource = find_resource(params)
  end

  def save(params)
    # In controllers we set PaperTrail metadata in
    # ProjectScoped#info_for_paper_trail, but now
    # we are not in a controller, so:
    PaperTrail.request.controller_info = { project_id: current_project.id }
    PaperTrail.request.whodunnit = current_user.email
    resource.paper_trail_event = 'auto-save'

    puts 'auto save is happening'

    if resource.update_attributes parsed_params(params['data'])
      track_activity
    end
  end

  private

  def parsed_params(data)
    wrapped_params = Rack::Utils.parse_nested_query data
    ActionController::Parameters.
      new(wrapped_params).
      require(@params['resource_type']).
      permit(permissable_params(@params['resource_type']))
  end

  def permissable_params(type)
    case type
    when 'issue' then %i[tag_list text]
    when 'evidence' then %i[author content issue_id node_id]
    when 'note' then %i[category_id text node_id]
    else []
    end
  end

  def find_resource(params)
    return unless %w[issue note evidence].include? params['resource_type']
    current_project.send(params['resource_type'].pluralize).find params['resource_id']
  end


  def track_activity
    ActivityTrackingJob.perform_later(
      action: 'auto-save',
      project_id: current_project.id,
      trackable_id: resource.id,
      trackable_type: resource.class.to_s,
      user_id: current_user.id
    )
  end
end
