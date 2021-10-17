require_dependency "ishapi/application_controller"
module Ishapi
  class TagsController < ApplicationController

    def index
      authorize! :index, Tag
      @tags = Tag.all
      if params[:domain]
        @site = Site.find_by( :domain => params[:domain], :lang => :en )
        @tags = @tags.where( :site => @site )
      end
    end

    def show
      begin
        @tag = Tag.find_by( slug: params[:slug] )
      rescue Mongoid::Errors::DocumentNotFound
        @tag = Tag.find params[:slug]
      end
      authorize! :show, @tag
    end

  end
end
