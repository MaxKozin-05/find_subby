# app/controllers/public/profiles_controller.rb
module Public
  class ProfilesController < ApplicationController
    def show
      @profile  = Profile.find_by!(handle: params[:handle])
      @projects = @profile.projects.with_attached_photos.order(created_at: :desc)
    end
  end
end
