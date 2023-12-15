
class Ishapi::ApplicationController < ActionController::Base

  def home
    render json: { status: :ok }
  end

end
