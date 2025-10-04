# app/policies/notification_policy.rb
class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def update?
    record.user_id == user.id
  end

  def mark_all_read?
    user.present?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      scope.where(user: user)
    end
  end
end
