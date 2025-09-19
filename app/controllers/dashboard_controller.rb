class DashboardController < ApplicationController
  def show
    skip_authorization
    
    @stats = {
      total_jobs: current_user.jobs.count,
      active_jobs: current_user.active_jobs_count,
      projects: 0,
      this_week_jobs: current_user.recent_jobs_count
    }
    
    @recent_jobs = current_user.jobs.order(created_at: :desc).limit(5)
  end
end
