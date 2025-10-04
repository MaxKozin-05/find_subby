# app/policies/quote_policy.rb
class QuotePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    admin_or_owner?
  end

  def create?
    user.present?
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner?
  end

  def duplicate?
    admin_or_owner?
  end

  def generate_pdf?
    admin_or_owner?
  end

  def pdf?
    admin_or_owner?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      scope.where(user: user)
    end
  end

  private

  def admin_or_owner?
    user&.admin? || record.user_id == user.id
  end
end
