
require_dependency "ishapi/application_controller"

class ::Ishapi::EmailMessagesController < ::Ishapi::ApplicationController

  before_action :check_jwt, only: [ :show ]
  layout false

  def show
    @msg = Office::EmailMessage.find( params[:id] )
    authorize! :show, @msg

    if params[:load_images]
      ;
    else
      if @msg.part_html
        doc = Nokogiri::HTML(@msg.part_html)
        images = doc.search('img')
        images.each do |img|
          img['src'] = 'missing'
        end
        @msg.part_html = doc
      end
    end

    respond_to do |format|
      format.json do
        render json: { item: @msg, }
      end
      format.html do
      end
    end
  end

  ## From lambda, ses
  def receive
    if params[:secret] != AWS_SES_LAMBDA_SECRET
      render status: 400, json: { status: 400 }
      return
    end

    msg = Office::EmailMessageStub.new({
      object_key:  params[:object_key],
    })
    if msg.save
      ::Ishapi::EmailMessageIntakeJob.perform_later( msg.id.to_s )
      render status: :ok, json: { status: :ok }
    else
      puts! msg.errors.full_messages, 'Could not save EmailMessageStub'
      render status: 400, json: { status: 400 }
    end
  end

end
