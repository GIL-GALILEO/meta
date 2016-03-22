module Admin
  class Admin < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :invitable, :database_authenticatable, :lockable,
           :recoverable, :rememberable, :trackable, :validatable
  end
end

