class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable, :rememberable, :trackable, :database_authenticatable, :omniauthable,
         omniauth_providers: [:twitter]


  # Setup accessible (or protected) attributes for your model
  # attr_accessible :remember_me, :name, :twitter_handle, :twitter_description, :twitter_description, :twitter_oauth, :website, :image


  has_many :letters
  has_many :likes
  has_many :external_identities
  has_one :twitter_identity, -> { where provider: 'twitter' }, class_name: "ExternalIdentity" 

  

  class << self
    def find_for_twitter_oauth(auth)
      user = User.joins(:external_identities)
             .where(external_identities: { uid: auth.uid, provider: auth.provider })
             .first
      if user
        user.update(name: auth.info.name)
        user.twitter_identity.update(
          handle: auth.info.nickname, 
          description: auth.info.description, 
          website: auth.info.urls.Website, 
          oauth: auth.credentials.token, 
          name: auth.info.name, 
          image: auth.info.image
        )
        user
      else
        user = User.create(name: auth.info.name)
        user.external_identities.create(
          uid: auth.uid, 
          provider: auth.provider, 
          handle: auth.info.nickname, 
          name: auth.info.name, 
          image: auth.info.image, 
          description: auth.info.description, 
          website: auth.info.urls.Website, 
          oauth: auth.credentials.token
        )    
        user
      end
    end
  end
end
