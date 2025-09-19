# app/controllers/jobs_controller.rb
class JobsController < ApplicationController
  before_action :set_job, only: [:show, :update]

  def index
    @jobs = policy_scope(Job).includes(:notifications).recent

    # Filter by status if provided
    if params[:status].present?
      if params[:status].is_a?(Array)
        @jobs = @jobs.where(status: params[:status])
      else
        @jobs = @jobs.where(status: params[:status])
      end
    end

    # Pagination could be added here if needed
    @jobs = @jobs.limit(50)
  end

  def show
    # Mark related notifications as read
    current_user.notifications.where(notifiable: @job).unread.update_all(read: true)
  end

  def update
    if @job.update(job_params)
      # Send notification to client if status changed to something meaningful
      if @job.saved_change_to_status? && %w[contacted quoted accepted declined].include?(@job.status)
        JobMailer.job_status_update(@job).deliver_later
      end

      redirect_to @job, notice: 'Job updated successfully.'
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_job
    @job = Job.find(params[:id])
    authorize @job
  end

  def job_params
    params.require(:job).permit(:status, :estimated_budget, :preferred_start_date)
  end
end
