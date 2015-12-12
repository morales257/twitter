class User < ActiveRecord::Base
 attr_accessor :remember_token
  before_save {self.email = email.downcase}
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
  validates :password, presence: true, length: {minimum: 6}
  
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
  
  def authenticated?(remember_token)
   #to make sure user is logged out in 2 separate browsers...
   return false if remember_digest.nil?
   #compare the hash with the remember token
   #not the same remember_token as above, but rather a local variable
   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def forget
   update_attribute(:remember_digest, nil)
  end
end
