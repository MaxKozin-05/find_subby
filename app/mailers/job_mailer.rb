# app/mailers/job_mailer.rb
class JobMailer < ApplicationMailer
  def new_job_request(job)
    @job = job
    @user = job.user
    @profile = @user.profile

    mail(
      to: @user.email,
      subject: "New Job Request: #{@job.title}",
      from: "notifications@findsubby.com"
    )
  end

  def job_status_update(job)
    @job = job
    @profile = @job.user.profile

    subject_text = case @job.status
    when 'contacted'
      "We've received your request"
    when 'quoted'
      "Quote ready for your project"
    when 'accepted'
      "Your project has been accepted"
    when 'declined'
      "Update on your project request"
    else
      "Update on your job request"
    end

    mail(
      to: @job.client_email,
      subject: "#{subject_text}: #{@job.title}",
      from: "notifications@findsubby.com"
    )
  end
end
