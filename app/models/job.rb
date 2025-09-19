# app/models/job.rb
class Job < ApplicationRecord
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :client_name, :client_email, :title, presence: true
  validates :client_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :client_phone, format: { with: /\A[\+]?[0-9\s\-\(\)]+\z/ }, allow_blank: true

  enum status: {
    lead: 0,
    contacted: 1,
    quoted: 2,
    accepted: 3,
    in_progress: 4,
    completed: 5,
    declined: 6,
    cancelled: 7
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: [:lead, :contacted, :quoted, :accepted, :in_progress]) }

  after_create :create_notification, :send_new_job_email

  def display_budget
    estimated_budget.present? ? "$#{estimated_budget}" : "TBD"
  end

  def days_since_submitted
    (Date.current - created_at.to_date).to_i
  end

  private

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
