require_dependency "ishapi/application_controller"

class Ishapi::ProductsController < Ishapi::ApplicationController

  # before_action :soft_check_long_term_token, only: [ :show ]
  before_action :check_jwt

  def show
    @product = Wco::Product.find params[:id]

    puts! @product.prices.to_a, 'to_a'

    authorize! :show, @product
  end

end