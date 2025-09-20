# app/models/calendar_day.rb
class CalendarDay < ApplicationRecord
  belongs_to :user

  validates :day, presence: true, uniqueness: { scope: :user_id }
  validates :state, presence: true

  enum state: {
    available: 0,
    busy: 1,
    booked: 2
  }

  scope :for_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(day: start_date..end_date)
  }

  scope :for_date_range, ->(start_date, end_date) {
    where(day: start_date..end_date)
  }

  def self.state_for_day(user, date)
    find_by(user: user, day: date)&.state || 'available'
  end

  def self.toggle_state(user, date)
    calendar_day = find_or_initialize_by(user: user, day: date)

    case calendar_day.state
    when 'available', nil
      calendar_day.state = 'busy'
    when 'busy'
      calendar_day.state = 'available'
    when 'booked'
      # Booked days can only be changed manually (from jobs)
      return calendar_day
    end

    calendar_day.save!
    calendar_day
  end

  def color_class
    case state
    when 'available'
      'bg-green-100 text-green-800 border-green-200'
    when 'busy'
      'bg-red-100 text-red-800 border-red-200'
    when 'booked'
      'bg-blue-100 text-blue-800 border-blue-200'
    end
  end

  def display_state
    state.humanize
  end
end
