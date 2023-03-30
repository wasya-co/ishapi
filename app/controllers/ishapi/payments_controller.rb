require_dependency "ishapi/application_controller"
class Ishapi::PaymentsController < ::Ishapi::ApplicationController

  before_action :check_profile, only: %i| create unlock |

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: %i| stripe_confirm |

  # alphabetized : )

  ## _vp_ 2020-07-21 This is for guyd
  ## _vp_ 2022-03-01 It's been a while!
  ## _vp_ 2022-09-04 continue
  ## _vp_ 2023-03-29 Continue
  ##
  ## @TODO: cannot proceed if already is_purchasing?
  ## @TODO: and this doesn't say what you're buying! herehere
  ##
  def create
    authorize! :create, Ish::Payment.new

    @current_profile.update_attributes({ is_purchasing: true })

    amount_cents  = params[:amount_cents].to_i # @TODO: change

    ::Stripe.api_key = ::STRIPE_SK
    intent = Stripe::PaymentIntent.create({
      amount: amount_cents,
      currency: 'usd',
      metadata: { integration_check: "accept_a_payment" },
    })

    item_type = case params[:item_type]
    when 'Ish::Location'
      'Gameui::Map'
    else
      throw "item_type not implemented: #{params[:item_type]}"
    end
    item = item_type.constantize.find params[:item_id]

    payment = Ish::Payment.create!(
      client_secret: intent.client_secret,
      email: @current_profile.email,
      item: item,
      payment_intent_id: intent.id,
      profile_id: @current_profile.id,
    )
    render json: {
      client_secret: intent.client_secret,
      clientSecret: intent.client_secret,
    }

  end

  ##
  ## webhook
  ## _vp_ 2023-03-29 Continue
  ##
  def stripe_confirm
    authorize! :open_permission, ::Ishapi
    payload = request.body.read
    event = nil
    begin
      event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    rescue StandardError => err
      puts! err, 'could not #stripe_confirm'
      render status: 400, json: { status: :not_ok }
      return
    end

    payment_intent = event.data.object
    puts! payment_intent, 'payment_intent'

    payment = Ish::Payment.where( payment_intent_id: payment_intent.id ).first
    if payment && payment_intent['status'] == 'succeeded'

      payment.update_attributes( status: Ish::Payment::STATUS_CONFIRMED )
      n_unlocks = payment.profile.n_unlocks + 1 # @TODO: it's not always 5, adjust! herehere

      payment.profile.update_attributes!( n_unlocks: n_unlocks, is_purchasing: false )
    end

    render status: 200, json: { status: :ok }
  end

  ##
  ## Spend an unlock without spending money. _vp_ 2022-03-01
  ##
  def unlock
    authorize! :unlock, ::Ish::Payment
    item = Object::const_get(params['kind']).find params['id']

    existing = Ish::Payment.where( profile: @current_profile, item: item ).first
    if existing
      render status: 200, json: { status: :ok, message: 'already purchased' }
      return
    end

    @current_profile.inc( n_unlocks: -item.premium_tier )

    purchase = ::Ish::Payment.create!( item: item, profile: @current_profile, )

    @profile = @current_profile
    render 'ishapi/user_profiles/account'
  end

end

