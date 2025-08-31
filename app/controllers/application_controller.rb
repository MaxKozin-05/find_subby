class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Require login for everything except public & Devise (sign-in/sign-up/etc.)
  before_action :authenticate_user!, unless: :skip_auth?

  # Pundit verification hooks (help catch missing authorize/scope calls)
  after_action :verify_authorized,     except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped,  only:   :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path, alert: "Not authorized."
  end

  private

  # Skip auth on public controllers, Devise controllers, and dev tools like Letter Opener
  def skip_auth?
    public_controller? || devise_controller? || letter_opener?
  end

  # Skip Pundit checks on the same set
  def skip_pundit?
    public_controller? || devise_controller? || letter_opener?
  end

  # Your public surface (mini-site, home, errors)
  def public_controller?
    controller_path.start_with?("public/") || controller_name.in?(%w[home errors])
  end

  # Dev tool route (only if mounted)
  def letter_opener?
    defined?(LetterOpenerWeb) && controller_path.start_with?("letter_opener_web/")
  end
end
