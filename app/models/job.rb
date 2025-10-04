# app/models/job.rb
class Job < ApplicationRecord
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :job_blocks, dependent: :destroy

  validates :client_name, :client_email, :title, presence: true
  validates :client_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :client_phone, format: { with: /\A[\+]?[0-9\s\-\(\)]+\z/ }, allow_blank: true
  validate :work_dates_are_valid

  enum status: {
    lead: 0,
    quoted: 1,
    won: 2,
    in_progress: 3,
    completed: 4,
    lost: 5
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: [:lead, :quoted, :won, :in_progress]) }
  scope :in_flight, -> { where(status: [:won, :in_progress]) }

  after_create :create_notification, :send_new_job_email

  def display_budget
    estimated_budget.present? ? "$#{estimated_budget}" : "TBD"
  end

  def days_since_submitted
    (Date.current - created_at.to_date).to_i
  end

  private

  def work_dates_are_valid
    return if starts_on.blank? || ends_on.blank?

    if ends_on < starts_on
      errors.add(:ends_on, 'must be on or after the start date')
    end
  end

  def create_notification
    Notification.create!(
      user: user,
      notifiable: self,
      title: "New Job Request",
      message: "#{client_name} has requested a quote for: #{title}",
      notification_type: "new_job"
    )
  end

  def send_new_job_email
    JobMailer.new_job_request(self).deliver_later
  end
end
