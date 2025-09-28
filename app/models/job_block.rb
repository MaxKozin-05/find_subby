# app/models/job_block.rb
class JobBlock < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :starts_on, :ends_on, presence: true
  validate :ends_on_after_starts_on

  scope :covering, ->(date) { where('starts_on <= ? AND ends_on >= ?', date, date) }

  private

  def ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, 'must be on or after the start date') if ends_on < starts_on
  end
end
