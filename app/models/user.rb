
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { subbie: 0, admin: 1 }
  enum plan: { free: 0, pro: 1 }

  has_one :profile, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :job_blocks, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :calendar_days, dependent: :destroy
  has_many :quotes, dependent: :destroy  # ADD THIS LINE

  def unread_notifications_count
    notifications.unread.count
  end

  def recent_jobs_count
    jobs.where(created_at: 1.week.ago..).count
  end

  def active_jobs_count
    jobs.active.count
  end
end
