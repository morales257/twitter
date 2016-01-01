class User < ActiveRecord::Base
 attr_accessor :remember_token, :activation_token, :reset_token
  before_save {self.email = email.downcase}
  #call create_activation_digest before creating a new user in the db
  before_create :create_activation_digest
  #validates is a method with two arguments, a symbol and a hash
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #you need to add case sensitivity to uniqueness
  #without it foo@bar.com != FOO@BAR.COM
  validates :email, presence: true, length: {maximum: 255}, 
                format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
 
 #...each user can have many microposts
 has_many :microposts, dependent: :destroy
 
 # because there does not exist and active_relationship symbol, we have to tell
 #rails which class to look for
 #rails makes associations through the foreign_key
 #rails by default expects the foreign key to be <class>_id, but since we are
 #using follower_id for association, we have to make it explicit
 has_many :active_relationships, class_name: "Relationship", 
                                 foreign_key: "follower_id",
                                 dependent: :destroy
 
 #when a user has followers, it can be said that they have a passive relationship
 #since the other user followed the current user, and since a user can have many
 #followers, we can make a has_many association
 has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
 
 
 
 #by default Rails looks for a foreign_key corresponding to the singular version
 #of association (followed for followed_id)
 #since we are using following, we have to indicate the source of the foreign key
 has_many :following, through: :active_relationships, source: :followed
 
 has_many :followers, through: :passive_relationships, source: :follower
  
  has_secure_password
  #TO WORK, MODEL NEEDS password_digest attribute
  #allows you to save a hashed password
  #presence validation and matchin validation when login in
  #authentication that returns user if password is correct
  #we allow nil for when users dont want to update a password, but not for
  #signing up, because has_secure_password has its own presence validator
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true
  
   def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
   end

 #step 1 to remembering a user
  def User.new_token
   SecureRandom.urlsafe_base64
  end
  
  def remember
   #self ensures assignments sets the user's remember_token attribute
   #and not a local variable
   #step 2: make a new remember token for a user
   self.remember_token = User.new_token
   #Step 3: update the remember digest with the result of applying User.digest
   #on the token
   update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  #update authenticated? to take activation tokens as well
  def authenticated?(attribute, token)
   digest = self.send("#{attribute}_digest")
   #to make sure user is logged out in 2 separate browsers use remember_digest
   return false if digest.nil?
   #compare the hash with the remember token
   #not the same remember_token as above, but rather a local variable
   BCrypt::Password.new(digest).is_password?(token)
  end
  
  def forget
   update_attribute(:remember_digest, nil)
  end
  
  #activated an account
  def activate
   update_attribute(:activated, true)
   update_attribute(:activated_at, Time.zone.now)
  end
  
  #Sends activation email
  def send_activation_email
   UserMailer.account_activation(self).deliver_now
  end
  
  #Sets the password reset attributes (which we send to user) in PW Reset Controller
  def create_reset_digest
   self.reset_token = User.new_token
   update_attribute(:reset_digest, User.digest(reset_token))
   update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  #Send password reset email
  def send_password_reset_email
   UserMailer.password_reset(self).deliver_now
  end
  
  #Returns true if a password reset has expired
  #used as a callback to password resets edit and update functions
  def password_reset_expired?
   #read as reset sent earlier than 2 hours ago
   reset_sent_at < 2.hours.ago
  end
  
  #Defines a proto-feed and currently shows all the users posts and followers posts
  # ? escapes the id propoerly before being included in the underlying SQL
  #query therby avoiding SQL injection
  def feed
   #for efficiency when we have large amounts of followers, we push the findings
   # of follower user ids into the db using a subselect
   following_ids = "SELECT followed_id FROM relationships
                    WHERE follower_id = :user_id"
   Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
   #the above is the same as calling following.map(&:id), mapping users 
   #followed by id. Above we also add our own id
  end
  
  #with the has_many :through relationships defined above, we can create
  #powerful utilit methods that can help us follow and unfollow users
  
  #Follows a user
  def follow(other_user)
   #active relationships creates a follower_id, and this creates an active 
   #relationship associaeted with user
   active_relationships.create(followed_id: other_user.id)
  end
  
  #Unfollows a user
  def unfollow(other_user)
   active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # Returns true of the current user is following the other user
  def following?(other_user)
   #due to the association above, has_many :following, we can make this
   #association
   following.include?(other_user)
  end
  
  private
  
  def create_activation_digest
   self.activation_token = User.new_token
   self.activation_digest = User.digest(activation_token)
  end
end
