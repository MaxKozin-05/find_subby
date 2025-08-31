class ProfilePolicy < ApplicationPolicy
  def show?   = admin_or_owner?
  def create? = user.present?
  def update? = admin_or_owner?

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      scope.where(user_id: user.id)
    end
  end

  private
  def admin_or_owner?
    user&.admin? || record.user_id == user.id
  end
end
