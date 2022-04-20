require_dependency "ishapi/application_controller"

module Ishapi
  class NewsitemsController < ApplicationController

    before_action :check_profile

    def destroy
      n = Newsitem.find params[:id]

      puts! n.map.creator_profile.id, 'ze id'
      puts! current_user.profile.id, 'ze2 id'

      authorize! :destroy, n
      flag = n.destroy
      if flag
        render json: { status: 'ok' }, status: :ok
      else
        render json: { message: "No luck: #{n.errors.full_messages.join(", ")}." }, status: 400
      end
    end

    def index
      if params[:domain]
        resource = Site.find_by( :domain => params[:domain], :lang => :en )
      else
        resource = current_user.profile
      end

      authorize! :show, resource
      @newsitems = current_user.profile.newsitems
    end

  end
end
