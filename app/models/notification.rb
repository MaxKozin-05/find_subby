# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :title, :notification_type, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read: true)
  end

  def time_ago
    case
    when created_at > 1.hour.ago
      "#{((Time.current - created_at) / 1.minute).round}m ago"
    when created_at > 1.day.ago
      "#{((Time.current - created_at) / 1.hour).round}h ago"
    when created_at > 1.week.ago
      "#{((Time.current - created_at) / 1.day).round}d ago"
    else
      created_at.strftime("%b %d")
    end
  end
end
