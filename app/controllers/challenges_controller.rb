class ChallengesController < ApplicationController
  before_action :set_challenge, only: %i[ show edit update destroy ]

  # GET /challenges or /challenges.json
  def index
    @challenges = Challenge.all
  end

  # GET /challenges/1 or /challenges/1.json
  def show
  end

  # GET /challenges/new
  def new
    @challenge = Challenge.new
  end

  # GET /challenges/1/edit
  def edit
  end

  # POST /challenges or /challenges.json
  def create

    @challenge = Challenge.new(challenge_params)
  
    # stock the number of guest from params
    @num_guest = @challenge.numb_guest

    # stock the meal category
    @meal_category = @challenge.meal_category
  
    respond_to do |format|
      if @challenge.save

        # Associate on Event table the new challenge whit the current_user
        @owner_event = Event.create(user_id: current_user.id, challenge_id: @challenge.id, role: "créateur", participation: "confirmed")

        # fetch recipe on API and save it
        fetch_recipe(@meal_category, @owner_event)

        # create the number of Guest with the id of the current challenge
        @num_guest.times do
         Guest.create(email: "", username: "", challenge_id: @challenge.id)
        end

        format.html { redirect_to edit_challenge_path(@challenge), notice: "Challenge was successfully created." }
        format.json { render :show, status: :created, location: @challenge }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end


  end

  # PATCH/PUT /challenges/1 or /challenges/1.json
  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to @challenge, notice: "Challenge was successfully updated." }
        format.json { render :show, status: :ok, location: @challenge }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1 or /challenges/1.json
  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url, notice: "Challenge was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  #get MealDB user search keyword
  def search_mealdb
    recepies = mealdb_url(params[:meal_category])
    unless recepies
      flash[:alert] = 'Pas de recettes trouvées'
      return render action: :index
      @recipe = recepies.first
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_challenge
      @challenge = Challenge.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def challenge_params
      params.require(:challenge).permit(:title, :status, :description, :numb_guest, :meal_category)
    end

end
