# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  def index
    @notifications = policy_scope(Notification).recent.includes(:notifiable)
    @notifications = @notifications.where(read: false) if params[:unread] == 'true'
    @notifications = @notifications.limit(50) # Pagination
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    authorize @notification

    @notification.mark_as_read!

    # Redirect to the related object if possible
    if @notification.notifiable.is_a?(Job)
      redirect_to @notification.notifiable
    else
      redirect_back(fallback_location: notifications_path)
    end
  end

  def mark_all_read
    authorize current_user.notifications
    current_user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: 'All notifications marked as read.'
  end
end
