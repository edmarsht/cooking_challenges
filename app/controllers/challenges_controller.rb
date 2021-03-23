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

        @recipies = search_mealdb_category(@meal_category)
        @recipe = @recipies[rand(0...@recipies.length)]
        @my_recipe = get_recipe_by(@recipe["idMeal"])

        puts "----------------------------"
        puts @recipe = @recipies
        puts "----------------------------"
        puts @my_recipe
        puts "----------------------------"
        puts "----------------------------"

        # Associate on Event table the new challenge whit the current_user
        #@owner_event = Event.create(user_id: current_user.id, challenge_id: @challenge.id, role: "créateur", participation: "confirmed")

        # create the number of Guest with the id of the current challenge
        #@num_guest.times do
         #Guest.create(email: "", challenge_id: @challenge.id)
        #end

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

    #set MealDB Url with keyword
    def mealdb_url_keyword(name)
      request_api(
        "https://themealdb.p.rapidapi.com/search.php?s=Arrabiata"
      )
    end
    
    # ==>set MealDB Url with category
    def mealdb_url_category(category)
      request_api(
        "https://themealdb.p.rapidapi.com/search.php?c=list"
      )
    end

    #set MealDB Url with category
    def search_mealdb_category(category)
      request_api(
        "https://themealdb.p.rapidapi.com/filter.php?c=#{category}"
      )
    end

    
    # fetch the MealDb data
    def request_api(url)
      response = Excon.get(
        url,
        headers: {
          'X-RapidAPI-Host' => URI.parse(url).host,
          'X-RapidAPI-Key' => ENV['RAPIDAPI_API_KEY']
        }
      )

      @json_data = JSON.parse(response.body)
      @recipies = @json_data['meals']

      if response.status != 200
        return nil
      else
        return @recipies
      end
    end

    def get_recipe_by(id)
      request_api(
        "https://themealdb.p.rapidapi.com/lookup.php?i=#{id}"
      )
    end

end
