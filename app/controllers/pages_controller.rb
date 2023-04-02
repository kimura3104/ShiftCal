class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :admin, :attendance]

  def dashboard
  end

  def admin
  end

  def attendance
    @employees = Employee.all
  end
end
