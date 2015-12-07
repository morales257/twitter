class User < ActiveRecord::Base
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
end
