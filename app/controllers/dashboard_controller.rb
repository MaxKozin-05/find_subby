class DashboardController < ApplicationController
  def show
    skip_authorization
  end
end
