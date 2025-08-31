class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
    enum role: { subbie: 0, admin: 1 }
    enum plan: { free: 0, pro: 1 }
end
