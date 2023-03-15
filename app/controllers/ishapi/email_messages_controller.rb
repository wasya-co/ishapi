
require_dependency "ishapi/application_controller"

class ::Ishapi::EmailMessagesController < ::Ishapi::ApplicationController

  before_action :check_jwt, only: [ :show ]

  def show
    msg = Office::EmailMessage.find( params[:id] )
    authorize! :show, msg
    render json: {
      item: msg,
    }
  end

  ## From lambda, ses
  def receive
    if params[:secret] != AWS_SES_LAMBDA_SECRET
      render status: 400, json: { status: 400 }
      return
    end

    msg = Office::EmailMessageStub.new({
      object_path: params[:object_path],
      object_key:  params[:object_key],
    })
    if msg.save
      ::Ishapi::EmailMessageIntakeJob.perform_later( msg.id.to_s )
      render status: :ok, json: { status: :ok }
    else
      render status: 400, json: { status: 400 }
    end
  end

end
