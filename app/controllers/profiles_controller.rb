# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :normalize_profile_params!, only: :update

  def update
    @profile = current_user.profile || current_user.build_profile
    authorize @profile

    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile saved."
    else
      flash.now[:alert] = @profile.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def normalize_profile_params!
    # service areas: "a, b, c" -> ["a","b","c"]
    if (txt = params.dig(:profile, :service_area_text)).present?
      params[:profile][:service_areas] =
        txt.gsub(/\r/, '').split(/\n|,/).map(&:strip).reject(&:blank?)
    end

    # companies: "Lendlease, CPB" or newline list -> ["Lendlease","CPB"]
    if (txt = params.dig(:profile, :companies_text)).present?
      params[:profile][:companies_json] =
        txt.gsub(/\r/, '').split(/\n|,/).map(&:strip).reject(&:blank?)
    end
  end

  def profile_params
    params.require(:profile).permit(
      :business_name, :handle, :trade_type, :about, :logo,
      { service_areas: [] }, { companies_json: [] }
    )
    # Note: we don't permit *_text fields; we only read them to build arrays.
  end
end
