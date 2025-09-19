# app/controllers/public/jobs_controller.rb
module Public
  class JobsController < ApplicationController
    def create
      @profile = Profile.find_by!(handle: params[:handle])
      @job = @profile.user.jobs.build(job_params)

      if @job.save
        redirect_to public_profile_path(@profile.handle),
                   notice: 'Your job request has been submitted successfully! We\'ll be in touch soon.'
      else
        @projects = @profile.projects.with_attached_photos.order(created_at: :desc)
        flash.now[:alert] = @job.errors.full_messages.to_sentence
        render 'public/profiles/show', status: :unprocessable_entity
      end
    end

    private

    def job_params
      params.require(:job).permit(:client_name, :client_email, :client_phone,
                                  :title, :description, :estimated_budget,
                                  :preferred_start_date, :location)
    end
  end
end
