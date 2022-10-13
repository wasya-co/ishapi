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

    ## _vp_ 2020-07-21 This is for guyd
    ## _vp_ 2022-03-01 It's been a while!
    ## _vp_ 2022-09-04 continue
    ##
    ## @TODO: cannot proceed if already is_purchasing?
    ##
    def create2
      authorize! :create, ::Ish::Payment
      @current_profile.update_attributes({ is_purchasing: true })

      begin
        amount_cents  = params[:amount_cents].to_i # @TODO: change

        ::Stripe.api_key = ::STRIPE_SK
        intent = Stripe::PaymentIntent.create({
          amount: amount_cents,
          currency: 'usd',
          metadata: { integration_check: "accept_a_payment" },
        })

        payment = Ish::Payment.create!(
          client_secret: intent.client_secret,
          email: @current_profile.email,
          payment_intent_id: intent.id,
          profile_id: @current_profile.id,
        )

        render json: { client_secret: intent.client_secret }
      rescue Mongoid::Errors::DocumentNotFound => e
        puts! e, '#create2 Mongoid::Errors::DocumentNotFound'
        render :status => 404, :json => e
      end
    end

    ##
    ## webhook
    ##
    def stripe_confirm
      authorize! :open_permission, ::Ishapi
      payload = request.body.read
      event = nil
      begin
        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
      rescue StandardError => e
        puts! e, 'could not #stripe_confirm'
        render status: 400, json: { status: :not_ok }
        return
      end

      payment_intent = event.data.object

      payment = Ish::Payment.where( payment_intent_id: payment_intent.id ).first
      if payment && payment_intent['status'] == 'succeeded'

        payment.update_attributes( status: :confirmed )
        n_unlocks = payment.profile.n_unlocks + 1 # @TODO: it's not always 5? adjust

        payment.profile.update_attributes!( n_unlocks: n_unlocks, is_purchasing: false )
      end

      render status: 200, json: { status: :ok }
    end

    def unlock
      authorize! :unlock, ::Ish::Payment
      item = Object::const_get(params['kind']).find params['id']

      existing = Purchase.where( user_profile: @current_profile, item: item ).first
      if existing
        render status: 200, json: { status: :ok, message: 'already purchased' }
        return
      end

      @current_profile.inc( n_unlocks: -item.premium_tier )

      purchase = ::Gameui::PremiumPurchase.create!( item: item, user_profile: @current_profile, )

      @profile = @current_profile
      render 'ishapi/user_profiles/account'
    end

  end
end

