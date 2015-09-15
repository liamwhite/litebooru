class ReportsController < ApplicationController
  def index
    if current_user
      @reports = current_user.reports.page(params[:page]).per(25)
    end
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new
    @report.assign_attributes(params.require(:report).permit(Report::ALLOWED_PARAMETERS))
    if @report.save
      redirect_to reports_path
    else
      render action: 'new'
    end
  end
end