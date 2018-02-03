class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  URL = 'http://ec2-35-164-197-212.us-west-2.compute.amazonaws.com:5000/events:'

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  def show
    @data = JSON.parse(RestClient.get(URL + 'Apple').body)

    @keyword = @data['keyword']
    @hashtag = @data['hashtag']
    @start_date = @data['start_date']
    @end_date = @data['end_date']
    @sentiment_score = @data['sentiment_score']
    @clusters = @data['clusters']
    @num_tweets = @data['num_tweets']
    @num_retweets = @data['num_retweets']


    @clusters_data = []
    @tweets = {}

    @currently_selected_cluster_id = @clusters[0]['id']

    @clusters.each_with_index do |cluster|
      chart_data = {
        id: cluster['id'],
        backgroundColor: "rgba(255,221,50,0.2)",
        borderColor: "rgba(255,221,50,1)",
        data: [{
            x: cluster['sentiment_score'],
            y: 2,
            r: cluster['num_tweets'] / @num_tweets * 10
        }]
      }
      tweets_data = $tc.oembeds(cluster['tweets_id'])
      @clusters_data.append(chart_data)
      @tweets[cluster['id']] = tweets_data
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(
			     :name, :keywords, :hashtags, :start_time, :end_time
		  )
    end
end
