# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :set_profile
  before_action :normalize_profile_params!, only: [:update]

  def show
    # Simple: just show the profile, no automatic redirects
    @projects = @profile.projects.with_attached_photos.order(created_at: :desc)
  end

  def edit
    # Simple: setup mode ONLY when URL has ?setup=true
    @setup_mode = params[:setup] == 'true'
  end

  def update
    @setup_mode = params[:setup] == 'true'

    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = @profile.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.create_profile!(default_profile_attributes)
    authorize @profile
  end

  def default_profile_attributes
    email_name = current_user.email.split('@').first
    {
      business_name: email_name.titleize,
      handle: email_name.parameterize,
      setup_complete: false
    }
  end

  def normalize_profile_params!
    if (txt = params.dig(:profile, :service_area_text)).present?
      params[:profile][:service_areas] =
        txt.gsub(/\r/, '').split(/\n|,/).map(&:strip).reject(&:blank?)
    end

    if (txt = params.dig(:profile, :companies_text)).present?
      params[:profile][:companies_json] =
        txt.gsub(/\r/, '').split(/\n|,/).map(&:strip).reject(&:blank?)
    end

    # Always mark as complete when saving
    params[:profile][:setup_complete] = true
  end

  def profile_params
    params.require(:profile).permit(
      :business_name, :handle, :trade_type, :about, :logo, :setup_complete,
      { service_areas: [] }, { companies_json: [] }
    )
  end
end
