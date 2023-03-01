
require_dependency "ishapi/application_controller"

module Ishapi
  class EmailMessagesController < ApplicationController

    before_action :check_jwt, only: [ :show ]

    def show
      m = Office::EmailMessage.find( params[:id] )
      authorize! :email_messages_show, ::Ishapi
      render json: {
        item: m,
      }
    end

    def receive
      if params[:secret] != AWS_SES_LAMBDA_SECRET
        render status: 400, json: { status: 400 }
        return
      end

      msg = Office::EmailMessage.new({
        object_path: params[:object_path],
        object_key: params[:object_key],
      })
      if msg.save
        render status: :ok, json: { status: :ok }
      else
        render status: 400, json: { status: 400 }
      end
    end

  end
end
