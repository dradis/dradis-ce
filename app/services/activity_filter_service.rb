# frozen_string_literal: true

class ActivityFilterService
  # Initializes the ActivityFilterService.
  #
  # @param activities [ActiveRecord::Relation] Collection of activities to filter
  # @param params [Hash] Filter parameters:
  #   @option params [String] :user_id The user ID to filter by
  #   @option params [String] :trackable_type The trackable type to filter by  
  #   @option params [String] :date Specific date to filter by (YYYY-MM-DD)
  #   @option params [String] :start_date Start date for range filter (YYYY-MM-DD)
  #   @option params [String] :end_date End date for range filter (YYYY-MM-DD)
  def initialize(activities, params)
    @activities = activities
    @params = params
  end

  def call
    query = @activities
    query = filter_by_user(query) if @params[:user_id].present?
    query = filter_by_trackable_type(query) if @params[:trackable_type].present?
    query = filter_by_specific_date(query) if @params[:date].present?
    query = filter_by_date_range(query) if @params[:start_date].present? && @params[:end_date].present?
    query
  end

  private

  def filter_by_user(query)
    return query unless @params[:user_id].present?

    query.where(user_id: @params[:user_id])
  end

  def filter_by_trackable_type(query)
    return query unless @params[:trackable_type].present?

    query.where(trackable_type: @params[:trackable_type])
  end

  def filter_by_specific_date(query)
    return query unless @params[:date].present?

    date = Date.parse(@params[:date]) rescue nil
    return query if date.nil?

    query.where(created_at: date.beginning_of_day..date.end_of_day)
  end

  def filter_by_date_range(query)
    return query unless @params[:start_date].present? && @params[:end_date].present?

    start_date = Date.parse(@params[:start_date]) rescue nil
    end_date = Date.parse(@params[:end_date]) rescue nil
    return query if start_date.nil? || end_date.nil?

    query.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  end
end
