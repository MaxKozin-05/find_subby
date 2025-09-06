# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user
  has_many  :projects, dependent: :destroy

  has_one_attached :logo

  validates :business_name, :handle, presence: true
  validates :handle, uniqueness: true

  before_validation :ensure_handle

  def companies
    Array(companies_json)
  end

  def companies=(arr)
    self.companies_json = Array(arr).map(&:to_s).map(&:strip).reject(&:blank?)
  end

  # Check if the profile has been set up properly
  def setup_complete?
    setup_complete && business_name.present? && trade_type.present?
  end

  # Check if profile is ready for public display
  def public_ready?
    setup_complete? && about.present?
  end

  private

  def ensure_handle
    return if handle.present? && handle.match?(/\A[a-z0-9\-]+\z/)
    base = (business_name.presence || user&.email&.split('@')&.first || 'profile').parameterize
    self.handle = unique_handle(base)
  end

  def unique_handle(base)
    h = base
    i = 1
    while Profile.where.not(id: id).exists?(handle: h)
      i += 1
      h = "#{base}-#{i}"
    end
    h
  end
end
