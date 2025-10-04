class DashboardController < ApplicationController
  def show
    skip_authorization

    @stats = {
      total_jobs: current_user.jobs.count,
      active_jobs: current_user.active_jobs_count,
      total_quotes: current_user.quotes.count,  # ADD THIS
      active_quotes: current_user.quotes.where(status: [:draft, :sent]).count,  # ADD THIS
      projects: current_user.profile&.projects&.count || 0,
      this_week_jobs: current_user.recent_jobs_count
    }

    @recent_jobs = current_user.jobs.order(created_at: :desc).limit(5)
    @recent_quotes = current_user.quotes.order(created_at: :desc).limit(3)  # ADD THIS
    @in_progress_jobs = current_user.jobs.in_flight.order(starts_on: :asc).limit(5)
  end
end
