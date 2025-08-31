class ProjectsController < ApplicationController
  def index
    @projects = policy_scope(Project).order(created_at: :desc)
  end

  def new
    @project = current_profile.projects.build
    authorize @project
  end

  def create
    @project = current_profile.projects.build(project_params)
    authorize @project
    if @project.save
      redirect_to projects_path, notice: 'Project created.'
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = Project.find(params[:id])
    authorize @project
  end

  def update
    @project = Project.find(params[:id])
    authorize @project
    if @project.update(project_params)
      redirect_to projects_path, notice: 'Project updated.'
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize @project
    @project.destroy
    redirect_to projects_path, notice: 'Project deleted.'
  end

  private
  def current_profile
    current_user.profile || current_user.create_profile!(business_name: current_user.email.split('@').first.titleize)
  end

  def project_params
    params.require(:project).permit(:title, :description, photos: [])
  end
end
