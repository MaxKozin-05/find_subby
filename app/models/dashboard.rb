# app/controllers/dashboard_controller.rb (updated)
class DashboardController < ApplicationController
  def show
    skip_authorization

    @recent_jobs = current_user.jobs.recent.limit(5)
    @unread_notifications = current_user.notifications.unread.recent.limit(5)
    @stats = {
      total_jobs: current_user.jobs.count,
      active_jobs: current_user.jobs.active.count,
      projects: current_user.profile&.projects&.count || 0,
      this_week_jobs: current_user.recent_jobs_count
    }
  end
end
