class User < ActiveRecord::Base
 attr_accessor :remember_token, :activation_token
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
  
  private
  
  def create_activation_digest
   self.activation_token = User.new_token
   self.activation_digest = User.digest(activation_token)
  end
end
