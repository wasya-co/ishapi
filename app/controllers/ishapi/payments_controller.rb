require_dependency "ishapi/application_controller"
module Ishapi
  class PaymentsController < ApplicationController

    before_action :check_profile, only: %i| create2 unlock |

    # alphabetized : )

    ##
    ## this is for invoices on wasya.co, isn't it?
    ## 20200712
    ##
    def create
      authorize! :open_permission, ::Ishapi
      begin
        invoice = Ish::Invoice.where( :email => params[:email], :number => params[:number] ).first
        payment = Ish::Payment.new :invoice => invoice, :email => params[:email], :amount => params[:amount]
        amount_cents  = ( params[:amount].to_f * 100 ).to_i

        ::Stripe.api_key = STRIPE_SK
        acct = Stripe::Account.create(
          :country => 'US',
          :type => 'custom'
        )
        charge = ::Stripe::Charge.create(
          :amount => amount_cents,
          :currency => 'usd',
          :source => params[:token][:id],
          :destination => {
            :account => acct,
          }
        )

        payment.charge = JSON.parse( charge.to_json )
        if payment.save
          render :json => { :status => :ok }
        else
          render :status => 404, :json => {}
        end
      rescue Mongoid::Errors::DocumentNotFound => e
        puts! e, 'e'
        render :status => 404, :json => {}
      end
    end

    ## This is for guyd _vp_ 20200721
    def create2
      authorize! :create, ::Ish::Payment

      begin
        amount_cents  = 503 # @TODO: change

        ::Stripe.api_key = STRIPE_SK
        intent = Stripe::PaymentIntent.create({
          amount: amount_cents,
          currency: 'usd',
          metadata: { integration_check: "accept_a_payment" },
        })

        payment = Ish::Payment.create!(
          client_secret: intent.client_secret,
          email: @current_user.email,
          payment_intent_id: intent.id,
          profile_id: @current_user.profile.id )

        render json: { client_secret: intent.client_secret }
      rescue Mongoid::Errors::DocumentNotFound => e
        puts! e, 'e'
        render :status => 404, :json => e
      end
    end

    ## webhook
    def stripe_confirm
      authorize! :open_permission, ::Ishapi
      payload = request.body.read
      event = nil
      begin
        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
      rescue StandardError => e
        puts! e, 'e'
        render status: 400, json: { status: :not_ok }
        return
      end

      payment_intent = event.data.object

      payment = Ish::Payment.where( payment_intent_id: payment_intent.id ).first
      if payment && payment_intent['status'] == 'succeeded'
        payment.update_attributes( status: :confirmed )
        payment.profile.update_attributes!( n_unlocks: payment.profile.n_unlocks + 5 )
      end

      render status: 200, json: { status: :ok }
    end

    def unlock
      authorize! :unlock, ::Ish::Payment
      item = Object::const_get(params['kind']).find params['id']

      puts! params, 'unlocking...'

      existing = Purchase.where( user_profile: @current_user.profile, item: item ).first
      if existing
        render status: 200, json: { status: :ok, message: 'already purchased' }
        return
      end

      @current_user.profile.update_attributes n_unlocks: @current_user.profile.n_unlocks - 1 # @TODO: the number is variable
      purchase = ::Gameui::PremiumPurchase.create!( item: item, user_profile: @current_user.profile, )

      render status: 200, json: { status: :ok }
    end

  end
end

