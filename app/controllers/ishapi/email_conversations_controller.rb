
require_dependency "ishapi/application_controller"

# gem_dir = Gem::Specification.find_by_name("ish_models").gem_dir
# require "#{gem_dir}/lib/office/email_conversation"

module Ishapi
  class EmailConversationsController < ApplicationController

    before_action :check_jwt

    def delete
      authorize! :email_conversations_delete, ::Ishapi
      convos = Office::EmailConversation.find params[:ids]
      outs = convos.map do |convo|
        convo.add_tag( WpTag::EMAILTAG_TRASH )
      end
      flash[:notice] = "outcome: #{outs}"
    end

  end
end
