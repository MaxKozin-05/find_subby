class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Auth everywhere except explicitly public/devise/dev tools
  before_action :authenticate_user!, unless: :skip_auth?

  # Pundit verification hooks (Rails 7.1-safe)
  after_action :verify_authorized, unless: -> { skip_pundit? || action_name == 'index' }
  after_action :verify_policy_scoped, if: -> { !skip_pundit? && action_name == 'index' }

  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path, alert: "Not authorized."
  end

  private

  def skip_auth?
    public_controller? || devise_controller? || letter_opener? || active_storage?
  end

  def skip_pundit?
    public_controller? || devise_controller? || letter_opener? || active_storage?
  end

  # Public surface (mini-site, home, errors)
  def public_controller?
    controller_path.start_with?("public/") || controller_name.in?(%w[home errors])
  end

  # Dev tools you mounted in dev
  def letter_opener?
    defined?(LetterOpenerWeb) && controller_path.start_with?("letter_opener_web/")
  end

  # Ignore Active Storage internal controllers (file uploads/variants)
  def active_storage?
    controller_path.start_with?("active_storage/")
  end
end
