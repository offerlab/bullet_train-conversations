class Account::ConversationsController < Account::ApplicationController
  account_load_and_authorize_resource :conversation, through: :team, through_association: :conversations

  # GET /account/teams/:team_id/conversations
  # GET /account/teams/:team_id/conversations.json
  def index
    # since we're showing conversations on the team show page by default,
    # we might as well just go there.
    redirect_to [:account, @team]
  end

  # GET /account/conversations/:id
  # GET /account/conversations/:id.json
  def show
    @menu_position = 'top'
    @body_class = 'conversations'
    @message = Conversations::Message.new(conversation: @conversation)
  end

  # GET /account/teams/:team_id/conversations/new
  def new
  end

  # GET /account/conversations/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/conversations
  # POST /account/teams/:team_id/conversations.json
  def create
    respond_to do |format|
      if @conversation.save
        format.html { redirect_to [:account, @team, :conversations], notice: I18n.t('conversations.notifications.created') }
        format.json { render :show, status: :created, location: [:account, @team, @conversation] }
      else
        format.html { render :new }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/conversations/:id
  # PATCH/PUT /account/conversations/:id.json
  def update
    respond_to do |format|
      if @conversation.update(conversation_params)
        format.html { redirect_to [:account, @conversation], notice: I18n.t('conversations.notifications.updated') }
        format.json { render :show, status: :ok, location: [:account, @conversation] }
      else
        format.html { render :edit }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/conversations/:id
  # DELETE /account/conversations/:id.json
  def destroy
    @conversation.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :conversations], notice: I18n.t('conversations.notifications.destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def conversation_params
      strong_params = params.require(:conversation).permit(
        :last_message_at,
        # 🚅 super scaffolding will insert new fields above this line.
        # 🚅 super scaffolding will insert new arrays above this line.
      )

      # 🚅 super scaffolding will insert processing for new fields above this line.

      strong_params
    end
end
