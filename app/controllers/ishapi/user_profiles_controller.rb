require_dependency "ishapi/application_controller"
module Ishapi
  class UserProfilesController < ApplicationController

    before_action :check_profile, only: %i| show | ## @TODO: hmmm I may not need this check at all

    before_action :check_profile_hard, only: %i| update |

    def show
      @profile = Ish::UserProfile.find_by :username => params[:username]
      authorize! :show, @profile
    end

    def update
      @profile = Ish::UserProfile.find @current_user.profile
      authorize! :update, @profile

      flag = @profile.update params[:profile].permit!
      if flag
        render json: { message: 'ok' }, status: :ok
      else
        render json: { message: "No luck: #{@profile.errors.full_messages.join(", ")}." }, code: 400
      end
    end

  end
end
