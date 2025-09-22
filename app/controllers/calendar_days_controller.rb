# app/controllers/calendar_days_controller.rb
class CalendarDaysController < ApplicationController
  before_action :set_calendar_day, only: [:show, :update, :destroy]

  def index
    # Skip Pundit policy scope since we're using our own service
    skip_policy_scope

    @year = params[:year]&.to_i || Date.current.year
    @month = params[:month]&.to_i || Date.current.month

    # Ensure valid month/year
    @month = [[1, @month].max, 12].min
    @year = [[2020, @year].max, 2030].min

    @calendar_data = Calendar::AvailabilityCompiler.for_month(current_user, @year, @month)
    @current_date = Date.new(@year, @month, 1)

    respond_to do |format|
      format.html
      format.json { render json: @calendar_data }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @calendar_day }
    end
  end

  def create
    @calendar_day = current_user.calendar_days.build(calendar_day_params)
    authorize @calendar_day

    if @calendar_day.save
      render json: @calendar_day, status: :created
    else
      render json: { errors: @calendar_day.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @calendar_day.update(calendar_day_params)
      render json: @calendar_day
    else
      render json: { errors: @calendar_day.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @calendar_day.destroy
    head :no_content
  end

  def toggle
    date = Date.parse(params[:date])
    @calendar_day = CalendarDay.toggle_state(current_user, date)

    render json: {
      date: date,
      state: @calendar_day.state,
      calendar_day: @calendar_day
    }
  rescue Date::Error
    render json: { error: 'Invalid date' }, status: :bad_request
  end

  def bulk_update
    dates = params[:dates] || []
    state = params[:state]

    unless CalendarDay.states.keys.include?(state)
      return render json: { error: 'Invalid state' }, status: :bad_request
    end

    updated_days = []

    dates.each do |date_str|
      begin
        date = Date.parse(date_str)
        calendar_day = current_user.calendar_days.find_or_initialize_by(day: date)
        calendar_day.state = state

        if calendar_day.save
          updated_days << {
            date: date,
            state: calendar_day.state,
            calendar_day: calendar_day
          }
        end
      rescue Date::Error
        # Skip invalid dates
        next
      end
    end

    render json: { updated_days: updated_days }
  end

  private

  def set_calendar_day
    @calendar_day = current_user.calendar_days.find(params[:id])
    authorize @calendar_day
  end

  def calendar_day_params
    params.require(:calendar_day).permit(:day, :state, :notes)
  end
end
