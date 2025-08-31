class ProjectPolicy < ApplicationPolicy
  def index?  = true
  def show?   = admin_or_owner?
  def create? = admin_or_owner?
  def update? = admin_or_owner?
  def destroy? = admin_or_owner?

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      scope.joins(:profile).where(profiles: { user_id: user.id })
    end
  end

  private
  def admin_or_owner?
    user&.admin? || record.profile.user_id == user.id
  end
end
