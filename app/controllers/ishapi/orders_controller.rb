require_dependency "ishapi/application_controller"

module Ishapi
  class OrdersController < ApplicationController
    before_action :check_profile, :only => [ :create ]

    def create
      authorize! :create, CoTailors::Order

      # params = {"token"=>{"id"=>"tok_1BoLkRDpn3WurCccVNQK4pfV", "object"=>"token", "card"=>{"id"=>"card_1BoLkRDpn3WurCccET5cyAMU", "object"=>"card", "address_city"=>nil, "address_country"=>nil, "address_line1"=>nil, "address_line1_check"=>nil, "address_line2"=>nil, "address_state"=>nil, "address_zip"=>"42424", "address_zip_check"=>"unchecked", "brand"=>"Visa", "country"=>"US", "cvc_check"=>"unchecked", "dynamic_last4"=>nil, "exp_month"=>4, "exp_year"=>2024, "funding"=>"credit", "last4"=>"4242", "metadata"=>{}, "name"=>nil, "tokenization_method"=>nil}, "client_ip"=>"76.103.54.198", "created"=>1516929079, "livemode"=>false, "type"=>"card", "used"=>false}, "accessToken"=>"EAAcgM1d2EyABAFAvisZBJy0vnlmunq1RM5rbcfUN0B1G6WGwulGkwqfJyP8Ue8Gb1DsyHyjLZCmEmMKKjhZCFF8JIyyZAGLLyqpIr8kg6wWhAIzLQ7HbYfmwFI8aZARtJB4ZBo4KZBbBx4wHUmLoPqAsG2Ca2DXKPkZD", "order"=>{"token"=>{"id"=>"tok_1BoLkRDpn3WurCccVNQK4pfV", "object"=>"token", "card"=>{"id"=>"card_1BoLkRDpn3WurCccET5cyAMU", "object"=>"card", "address_city"=>nil, "address_country"=>nil, "address_line1"=>nil, "address_line1_check"=>nil, "address_line2"=>nil, "address_state"=>nil, "address_zip"=>"42424", "address_zip_check"=>"unchecked", "brand"=>"Visa", "country"=>"US", "cvc_check"=>"unchecked", "dynamic_last4"=>nil, "exp_month"=>4, "exp_year"=>2024, "funding"=>"credit", "last4"=>"4242", "metadata"=>{}, "name"=>nil, "tokenization_method"=>nil}, "client_ip"=>"76.103.54.198", "created"=>1516929079, "livemode"=>false, "type"=>"card", "used"=>false}, "accessToken"=>"EAAcgM1d2EyABAFAvisZBJy0vnlmunq1RM5rbcfUN0B1G6WGwulGkwqfJyP8Ue8Gb1DsyHyjLZCmEmMKKjhZCFF8JIyyZAGLLyqpIr8kg6wWhAIzLQ7HbYfmwFI8aZARtJB4ZBo4KZBbBx4wHUmLoPqAsG2Ca2DXKPkZD"}}

      @order = CoTailors::Order.where( :profile_id => @current_profile.id, :submitted_at => nil ).first
      @order.submitted_at = Time.now

      Stripe.api_key = STRIPE_SK
      charge = Stripe::Charge.create :amount => @order.grand_total, :currency => 'usd', :source => params['token']['id']
      flag = charge.outcome[:type] == 'authorized'
      if !flag
        render :json => { :status => :not_ok, :message => "Something went wrong with the charge: " + charge.outcome.to_s }
        return
      end

      flag = @order.save
      if flag
        render :json => { :status => :ok, :message => 'Successfully placed the order' }
      else
        render :json => { :status => :not_ok, :error => @order.errors.messages }
      end
    end

  end
end
