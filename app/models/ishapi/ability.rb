
class Ishapi::Ability
  include ::CanCan::Ability

  def initialize user
    #
    # signed in user
    #
    unless user.blank?

      # if user.profile && user.profile.sudoer?
      #   can :manage, :all
      # end

      can [ :my_index ], Gallery
      can [ :show ], Gallery do |gallery|
        gallery.user_profile == user.profile
      end
      can [ :do_purchase ], ::Gameui

      can [ :create, :unlock ], ::Ish::Payment

      can [ :buy_stars ], ::Ish::UserProfile

    end
    #
    # anonymous user
    #
    user ||= User.new

    can [ :show ], Ish::UserProfile

    can [ :index, :show ], City

    can [ :index, :show ], Event

    #
    # G
    #
    can [ :index ], Gallery
    can [ :show ], Gallery do |gallery|
      gallery.is_public && !gallery.is_trash
    end

    #
    # I
    #
    can [ :fb_sign_in, :long_term_token, :open_permission, :welcome_home ], Ishapi

    #
    # M
    #
    can [ :index ], ::Gameui::Map
    can [ :show ], ::Gameui::Map do |map|
      map.is_public || map.shared_profiles.include?( user.profile )
    end
    can [ :show ], ::Gameui::Marker do |m|
      m.is_public
    end

    #
    # R
    #
    can [ :index ], Report
    can [ :my_index, :show ], Report do |report|
      report.is_public
    end

    #
    # S
    #
    can [ :index, :show ], Site

    #
    # T
    #
    can [ :index ], Tag
    can [ :show ], Tag do |tag|
      tag.is_public
    end

    #
    # V
    #
    can [ :index ], Venue
    can [ :show ], Venue do |venue|
      venue.is_public
    end
    can [ :index, :my_index ], Video
    can [ :show ], Video do |video|
      video.is_public
    end

  end
end
