
require_dependency "ishapi/application_controller"

# gem_dir = Gem::Specification.find_by_name("ish_models").gem_dir
# require "#{gem_dir}/lib/office/email_conversation"

module Ishapi
  class EmailConversationsController < ApplicationController

    before_action :check_jwt

    def delete
      puts! params, 'deleting email conversations'
      authorize! :email_conversations_delete, ::Ishapi
      convos = Office::EmailConversation.find params[:ids]
      convos.map &:destroy
    end

  end
end
