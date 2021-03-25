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
    
    # stock the meal area
    @meal_area = @challenge.meal_area
  
  


    respond_to do |format|
      if @challenge.save

        # Associate on Event table the new challenge whit the current_user
        @owner_event = Event.create(user_id: current_user.id, challenge_id: @challenge.id, role: "créateur", participation: "confirmed")

        # fetch recipe from area or from category on API and save it according to user choice
        # if @meal_category == nil || @meal_category == ""
        #   fetch_recipe_from_area(@meal_area, @owner_event)
        # elsif @meal_area == nil || @meal_area == ""
        #   fetch_recipe(@meal_category, @owner_event)
        # end


        # create the number of Guest with the id of the current challenge
        @num_guest.times do
        Guest.create(email: "", username: "", challenge_id: @challenge.id)
        end
        
        format.html { redirect_to edit_challenge_path(@challenge), notice: "Plus que quelques clic et ton challenge sera validé !" }
        format.json { render :show, status: :created, location: @challenge }


      else
        flash.now[:danger] = "Echec :" + @challenge.errors.full_messages.join(" ")
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /challenges/1 or /challenges/1.json
  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to edit_challenge_path, notice: "Ok, le challenge vient d'être modifié." }
        format.json { render :show, status: :ok, location: @challenge }
      else
        flash.now[:warning] = "Echec :" + @challenge.errors.full_messages.join(" ")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1 or /challenges/1.json
  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to user_path(current_user.id), notice: "Dommage, ton challenge n'est pas validé. tu pourras toujours un recréer un !!" }
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

  def search_mealdb_from_area
    recepies = mealdb_url(params[:meal_area])
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
      params.require(:challenge).permit(:title, :status, :description, :numb_guest, :meal_category, :meal_area, :theme_choice)
    end

end
