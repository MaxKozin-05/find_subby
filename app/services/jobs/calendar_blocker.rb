# app/services/jobs/calendar_blocker.rb
module Jobs
  class CalendarBlocker
    def initialize(job)
      @job = job
      @user = job.user
    end

    def apply!
      return unless @job.starts_on.present? && @job.ends_on.present?

      JobBlock.transaction do
        clear_existing_blocks

        block = @job.job_blocks.create!(
          user: @user,
          starts_on: @job.starts_on,
          ends_on: @job.ends_on
        )

        (@job.starts_on..@job.ends_on).each do |date|
          day = CalendarDay.find_or_initialize_by(user: @user, day: date)
          day.state = 'booked'
          day.save!
        end

        @job.update_column(:calendar_blocked, true)
        block
      end
    end

    def clear!
      JobBlock.transaction do
        @job.job_blocks.find_each do |block|
          release_range(block.starts_on, block.ends_on, except_block_id: block.id)
          block.destroy
        end
        @job.update_column(:calendar_blocked, false)
      end
    end

    private

    def clear_existing_blocks
      @job.job_blocks.find_each do |block|
        release_range(block.starts_on, block.ends_on, except_block_id: block.id)
        block.destroy
      end
    end

    def release_range(start_date, end_date, except_block_id: nil)
      (start_date..end_date).each do |date|
        next if other_blocks_cover_date?(date, except_block_id)

        day = CalendarDay.find_by(user: @user, day: date)
        next unless day

        day.update!(state: 'available') if day.state == 'booked'
      end
    end

    def other_blocks_cover_date?(date, except_block_id)
      scope = @user.job_blocks
      scope = scope.where.not(id: except_block_id) if except_block_id
      scope.covering(date).exists?
    end
  end
end
