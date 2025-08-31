class ApplicationPolicy
  attr_reader :user, :record
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = scope.where(id: record.id).exists?
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false
  def scope = Pundit.policy_scope!(user, record.class)

  class Scope
    attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  def resolve = scope.none
  end
end
