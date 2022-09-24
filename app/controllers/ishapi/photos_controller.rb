require_dependency "ishapi/application_controller"

class Ishapi::PhotosController < Ishapi::ApplicationController

  # before_action :soft_check_long_term_token, only: [ :show ]
  before_action :check_jwt

  def show
    @photo = Photo.find params[:id]
    authorize! :show, @photo
  end

end