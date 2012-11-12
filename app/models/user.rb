class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  
  has_many :corpora, :through => :memberships
  has_many :memberships
  
  scope :owners,		where(:memberships => {role: 'owner'})
  scope :approvers,		where(:memberships => {role: 'approver'})
  scope :members,		where(:memberships => {role: 'member'})
  
  
  def email_format
  	"#{self.name}<#{self.email}>"
  end
  
end
