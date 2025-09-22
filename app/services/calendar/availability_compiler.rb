module Calendar
  class AvailabilityCompiler
    attr_reader :user, :year, :month

    def initialize(user, year, month)
      @user = user
      @year = year.to_i
      @month = month.to_i
    end

    def compile
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month

      # Get all manual calendar days for the month
      manual_days = user.calendar_days.for_month(year, month).index_by(&:day)

      # Get all jobs that might affect availability
      jobs_in_month = user.jobs
        .where(status: [:accepted, :in_progress])
        .where.not(preferred_start_date: nil)
        .where(preferred_start_date: start_date..end_date)

      # Build the calendar data
      calendar_data = {}

      (start_date..end_date).each do |date|
        # Check for manual override first
        if manual_days[date]
          calendar_data[date] = {
            state: manual_days[date].state,
            source: 'manual',
            notes: manual_days[date].notes,
            calendar_day: manual_days[date]
          }
        else
          # Check if there's a job on this date
          job_on_date = jobs_in_month.find { |job| job.preferred_start_date == date }

          if job_on_date
            calendar_data[date] = {
              state: 'booked',
              source: 'job',
              job: job_on_date,
              notes: "Job: #{job_on_date.title}"
            }
          else
            calendar_data[date] = {
              state: 'available',
              source: 'default',
              notes: nil
            }
          end
        end
      end

      calendar_data
    end

    def self.for_month(user, year, month)
      new(user, year, month).compile
    end

    def self.state_for_date(user, date)
      manual_day = user.calendar_days.find_by(day: date)
      return manual_day.state if manual_day

      # Check for jobs on this date
      job_on_date = user.jobs
        .where(status: [:accepted, :in_progress])
        .where(preferred_start_date: date)
        .exists?

      return 'booked' if job_on_date
      'available'
    end
  end
end
