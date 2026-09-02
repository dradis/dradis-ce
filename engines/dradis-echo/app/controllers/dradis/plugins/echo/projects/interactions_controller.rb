module Dradis::Plugins::Echo
  class Projects::InteractionsController < AuthenticatedController
    include ProjectScoped
    include TurboConfigCheck
    layout false

    before_action :check_turbo_config, only: [:index]
    before_action :set_type
    before_action :set_prompt, only: [:preview]
    before_action :set_record
    before_action :set_liquid_assigns, only: [:preview]

    def index
      @prompts = Prompt.ensure_defaults_for!(current_user, @type)
      @sessions = Session.for_record(@record).order(updated_at: :desc)
    end

    def preview; end

    private

    def liquid_parse(template)
      options = {
        filters: [],
        strict_filters: true,
        strict_variables: true
      }

      Liquid::Template.parse(template).render(@liquid_assigns, options)
    end
    helper_method :liquid_parse

    def record_params
      params.permit(:id, :type, :project_id, :record)
    end

    # Resolved here, not in the liquid_parse helper: that runs mid-render inside a
    # lazy turbo-frame, where a raise surfaces as an empty frame, not an error.
    def set_liquid_assigns
      @liquid_assigns =
        case @type
        when :issue
          { 'issue' => IssueDrop.new(@record) }
        else
          raise ArgumentError, "Unsupported prompt scope: #{@type}"
        end
    end

    def set_prompt
      @prompt = current_user.prompts.for(@type).find(params[:id])
    end

    def set_record
      raise ActiveRecord::RecordNotFound if @type.blank?

      @record = current_project.send(@type.to_s.pluralize).find(record_params[:record])
    end

    def set_type
      allowed = Prompt::SCOPES.map(&:to_s)
      @type = allowed.include?(record_params[:type]) ? record_params[:type].to_sym : nil
    end
  end
end
