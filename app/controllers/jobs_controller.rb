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
    block_calendar = ActiveModel::Type::Boolean.new.cast(params.dig(:job, :block_calendar))

    if @job.update(job_params)
      handle_calendar_blocking(block_calendar)

      if @job.saved_change_to_status? && %w[quoted won in_progress completed lost].include?(@job.status)
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
    params.require(:job).permit(:status, :estimated_budget, :preferred_start_date, :starts_on, :ends_on)
  end

  def handle_calendar_blocking(block_calendar)
    block_calendar &&= @job.won? || @job.in_progress?

    blocker = Jobs::CalendarBlocker.new(@job)

    if block_calendar
      if @job.starts_on.present? && @job.ends_on.present?
        blocker.apply!
      else
        flash[:alert] = 'Add both start and finish dates to block your calendar.' if respond_to?(:flash)
      end
    elsif @job.calendar_blocked?
      blocker.clear!
    end
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.error("Calendar blocking failed for Job ##{@job.id}: #{error.message}")
    flash[:alert] = "Job saved, but we couldn't update the calendar: #{error.record.errors.full_messages.to_sentence}" if respond_to?(:flash)
  end
end
