

class Ishapi::My::ReportsController < Ishapi::ApplicationController

  def index
    authorize! :my_index, Report
    @reports = @profile.reports
  end

end

