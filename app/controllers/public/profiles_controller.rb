# app/controllers/public/profiles_controller.rb
module Public
  class ProfilesController < ApplicationController
    def show
      @profile  = Profile.find_by!(handle: params[:handle])
      @projects = @profile.projects.with_attached_photos.order(created_at: :desc)

      # Calendar data for the current month
      @current_month = Date.current.beginning_of_month
      @calendar_data = Calendar::AvailabilityCompiler.for_month(@profile.user, @current_month.year, @current_month.month)
    end
  end
end
