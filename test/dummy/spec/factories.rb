
FactoryBot.define do

  # alphabetic

  factory :city do
    name { 'City' }
    cityname { 'city' }
  end

  factory :gallery do
    name { 'xxTestxx' }
    slug { 'xxSlug' }
    after :build do |g|
      g.site ||= Site.new( :domain => 'xxDomainxx', :lang => 'xxLangxx' )
    end
  end

  factory :map, class: Gameui::Map do
    config { '{}' }
    labels { '{}' }
    name { 'map 1' }
    slug { 'map-1' }
    after :build do |m|
      image = Ish::ImageAsset.create({ image: File.open( Rails.root.join( 'data', 'photo.png' ) ) })
      m.image = image
      m.save
    end
  end

  factory :photo do
    after :build do |f|
      ph = Photo.create :photo => File.open( Rails.root.join( 'data', 'photo.png' ) )
      f.photo = ph
      f.save
    end
  end

  factory :report do
    name { 'blahblah' }
    after :build do |f|
      ph = Photo.create :photo => File.open( Rails.root.join( 'data', 'photo.png' ) )
      f.photo = ph
      f.save
    end
  end

  factory :site do
    domain { 'site.com' }
  end

  factory :tag do
    name { 'tag-name' }
    slug { 'slug-seo' }
  end

  factory :user do
    email { 'test@gmail.com' }
    password { '12345678' }

    factory :manager do
      email { 'manager@gmail.com' }
    end

    factory :piousbox do
      email { 'piousbox@gmail.com' }
    end
  end

end
