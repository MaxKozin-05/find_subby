class ProfilesController < ApplicationController
  def show
    @profile = current_user.profile || current_user.build_profile
    authorize @profile
  end

  def edit
    @profile = current_user.profile || current_user.build_profile
    authorize @profile
  end

  def update
    @profile = current_user.profile || current_user.build_profile
    authorize @profile

    if params[:profile][:service_area_text].present?
      params[:profile][:service_areas] = params[:profile][:service_area_text].split(',').map(&:strip).reject(&:blank?)
    end

    if params[:profile][:companies_text].present?
      raw = params[:profile][:companies_text].gsub(/\r/, '').split(/\n|,/)
      params[:profile][:companies_json] = raw.map(&:strip).reject(&:blank?)
    end

    if @profile.update(profile_params)
      redirect_to profile_path, notice: 'Profile saved.'
    else
      flash.now[:alert] = @profile.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def profile_params
    params.require(:profile).permit(:business_name, :handle, :trade_type, :about, :logo,
                                    service_areas: [], companies_json: [])
  end
end
