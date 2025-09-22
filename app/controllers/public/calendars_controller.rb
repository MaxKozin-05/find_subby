# app/controllers/public/calendars_controller.rb
module Public
  class CalendarsController < ApplicationController
    def show
      @profile = Profile.find_by!(handle: params[:handle])
      @user = @profile.user

      @year = params[:year]&.to_i || Date.current.year
      @month = params[:month]&.to_i || Date.current.month

      # Ensure valid month/year
      @month = [[1, @month].max, 12].min
      @year = [[2020, @year].max, 2030].min

      @calendar_data = Calendar::AvailabilityCompiler.for_month(@user, @year, @month)
      @current_date = Date.new(@year, @month, 1)

      respond_to do |format|
        format.html
        format.json { render json: @calendar_data }
      end
    end
  end
end
