
require_dependency "ishapi/application_controller"

module Ishapi
  class EmailMessagesController < ApplicationController

    def receive
      if params[:secret] != AWS_SES_LAMBDA_SECRET
        render status: 400, json: { status: 400 }
        return
      end

      msg = Office::EmailMessage.new({ object_path: params[:object_path] })
      if msg.save
        render status: :ok, json: { status: :ok }
      else
        render status: 400, json: { status: 400 }
      end
    end

  end
end
