class CardsController < AuthenticatedController
  include ActivityTracking
  include ContentFromTemplate
  include LockableResource
  include Mentioned
  include NotificationsReader
  include ProjectScoped

  # Not sorted because we need the Board and List first!
  before_action :set_current_board_and_list
  before_action :set_or_initialize_card
  before_action :initialize_sidebar, only: [:show, :new, :edit]
  before_action :set_auto_save_key, only: [:new, :create, :edit, :update]
  before_action :set_form_cancel_path, only: [:new, :edit]
  # Must run after :set_form_cancel_path; the lockout page links back to it.
  before_action :check_edit_lock, only: :edit

  layout 'cards'

  def show
    @lists = @board.ordered_lists
    render layout: !request.xhr?
  end

  def new
    # See ContentFromTemplate concern
    @card.description = template_content if params[:template]
  end

  def create
    @card.assign_attributes(card_params)
    # Set the new card as the last card of the list
    @card.previous_id = @list.last_card.try(:id)

    if @card.save
      track_created(@card)
      redirect_to [current_project, @board, @list, @card], notice: 'Task added.'
    else
      initialize_sidebar
      render 'new'
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      @card.release_edit_session(current_user)
      track_updated(@card)
      redirect_to [current_project, @board, @list, @card], notice: 'Task updated.'
    else
      initialize_sidebar
      render 'edit'
    end
  end

  def destroy
    if @card.destroy
      track_destroyed(@card)
      redirect_to [current_project, @board], notice: 'Task deleted'
    else
      redirect_to [current_project, @board, @list, @card], notice: "Error deleting task: #{@card.errors.full_messages.join('; ')}"
    end
  end

  private

  def card_params
    params.require(:card).permit(:name, :description, :due_date, assignee_ids: [])
  end

  def initialize_sidebar
    @sorted_cards = @list.ordered_cards.select(&:persisted?)
  end

  def lockable_resource
    @card
  end

  def set_or_initialize_card
    if params[:id]
      @card = @board.cards.find(params[:id])
      redirect_to [current_project, @board, @card.list, @card] if @card.list_id != @list.id
    else
      @card = @list.cards.new
    end
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list = @board.lists.includes(:cards).find(params[:list_id])
  end

  def set_auto_save_key
    @auto_save_key = if @card&.persisted?
      "card-#{@card.id}"
    elsif params[:template]
      "#{@list.id}-card-#{params[:template]}"
    else
      "#{@list.id}-card"
    end
  end

  def set_form_cancel_path
    if @card.new_record?
      @form_cancel_path = [current_project, @board]
    else
      @form_cancel_path = [current_project, @board, @list, @card]
    end
  end
end
