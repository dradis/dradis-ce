class CardsController < AuthenticatedController
  include ActivityTracking
  include Commented
  include ContentFromTemplate
  include ProjectScoped
  include Mentioned
  include NotificationsReader

  # Not sorted because we need the Board and List first!
  before_action :set_current_board_and_list
  before_action :set_card, only: [:show, :edit, :update, :destroy, :move]
  before_action :initialize_sidebar, only: [:show, :new, :edit]

  layout 'cards'

  def show
    @activities   = @card.activities.latest
    @subscription = @card.subscription_for(user: current_user)
    render layout: !request.xhr?
  end

  def new
    @card = @list.cards.new

    # See ContentFromTemplate concern
    @card.description = template_content if params[:template]
  end

  def create
    @card = @list.cards.new(card_params)
    # Set the new card as the last card of the list
    @card.previous_id = @list.last_card.try(:id)

    if @card.save
      track_created(@card)
      redirect_to [current_project, @board, @list, @card], notice: 'Task added.'
    else
      initialize_sidebar
      render "new"
    end
  end

  def edit
  end

  def update
    if @card.update_attributes(card_params)
      track_updated(@card)
      redirect_to [current_project, @board, @list, @card], notice: 'Task updated.'
    else
      initialize_sidebar
      render "edit"
    end
  end

  def move
    List.move(
      @card,
      prev_item: @board.cards.find_by(id: params[:prev_id]),
      next_item: @board.cards.find_by(id: params[:next_id])
    )

    if params[:new_list_id]
      @card.list = @board.lists.find(params[:new_list_id])
      @card.save
    end

    track_updated(@card)

    render json: {
      is_card:  true,
      id:       @card.id,
      link:     polymorphic_path([current_project, @board, @card.reload.list, @card]),
      moveLink: move_project_board_list_card_path(current_project, @board, @card.reload.list, @card)
    }
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

  def set_card
    @card = @list.cards.find(params[:id])
  end

  def set_current_board_and_list
    @board = current_project.boards.includes(:lists).find(params[:board_id])
    @list  = @board.lists.includes(:cards).find(params[:list_id])
  end
end
